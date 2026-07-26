/// A pending Khalti payment session, returned right after we ask the
/// backend to initiate a payment.
class KhaltiSession {
  final String pidx;
  final String paymentUrl;

  const KhaltiSession({required this.pidx, required this.paymentUrl});
}