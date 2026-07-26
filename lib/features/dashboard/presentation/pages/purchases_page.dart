import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kitabghar/core/api/api_endpoints.dart';
import 'package:kitabghar/core/extensions/context_extensions.dart';
import 'package:kitabghar/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:kitabghar/features/purchases/domain/entities/purchase_entity.dart';
import 'package:kitabghar/features/purchases/presentation/state/purchase_state.dart';
import 'package:kitabghar/features/purchases/presentation/view_model/purchase_view_model.dart';

class PurchasesScreen extends ConsumerStatefulWidget {
  const PurchasesScreen({super.key});

  @override
  ConsumerState<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends ConsumerState<PurchasesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    final token = ref.read(authViewModelProvider).user?.token;
    if (token == null || token.isEmpty) return;
    ref.read(purchaseViewModelProvider.notifier).getPurchases(token: token);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(purchaseViewModelProvider);

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: const Text('My Purchases'),
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        color: context.colors.primary,
        onRefresh: () async => _load(),
        child: _buildContent(state),
      ),
    );
  }

  Widget _buildContent(PurchaseState state) {
    if (state.isLoading && state.purchases.isEmpty) {
      return Center(
        child: CircularProgressIndicator(color: context.colors.primary),
      );
    }

    if (state.error != null && state.purchases.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 100),
          Center(
            child: Column(
              children: [
                Icon(Icons.wifi_off_rounded, size: 48, color: context.textTertiary),
                const SizedBox(height: 12),
                Text('Could not load your purchases',
                    style: TextStyle(
                        color: context.textSecondary,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      );
    }

    if (state.purchases.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 100),
          Center(
            child: Column(
              children: [
                Icon(Icons.receipt_long_outlined,
                    size: 56, color: context.textTertiary),
                const SizedBox(height: 12),
                Text('No purchases yet',
                    style: TextStyle(
                        color: context.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                const SizedBox(height: 4),
                Text('Books you buy from Explore will show up here',
                    style: TextStyle(color: context.textTertiary, fontSize: 12)),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: state.purchases.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _PurchaseTile(item: state.purchases[index]),
    );
  }
}

class _PurchaseTile extends StatelessWidget {
  final PurchaseEntity item;
  const _PurchaseTile({required this.item});

  Color _conditionColor(BuildContext context, String condition) {
    switch (condition) {
      case 'Like New':
        return const Color(0xFF2ECC71);
      case 'Good':
        return const Color(0xFF3FA7D6);
      case 'Fair':
        return const Color(0xFFF5A623);
      default:
        return context.textTertiary;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = ApiEndpoints.bookImageUrl(item.image);

    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 64,
              height: 84,
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _placeholder(context),
                    )
                  : _placeholder(context),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: context.textSecondary),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Rs. ${item.price}',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: context.colors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _conditionColor(context, item.condition),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.condition,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                if (item.createdAt != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Purchased ${_formatDate(item.createdAt)}',
                    style: TextStyle(fontSize: 10.5, color: context.textTertiary),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      color: context.isDarkMode
          ? const Color(0xFF2A2A2A)
          : const Color(0xFFF0F0F0),
      child: Icon(Icons.menu_book_rounded, color: context.textTertiary, size: 24),
    );
  }
}