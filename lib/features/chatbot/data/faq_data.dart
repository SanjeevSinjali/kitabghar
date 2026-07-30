class FaqEntry {
  final List<String> keywords;
  final String answer;

  const FaqEntry({required this.keywords, required this.answer});
}

const List<FaqEntry> faqData = [
  FaqEntry(
    keywords: ['hi', 'hello', 'hey', 'hola', 'namaste'],
    answer:
        "Hey there! 👋 I'm the KitabGhar assistant. Ask me about buying, selling, payments, or your account.",
  ),
  FaqEntry(
    keywords: ['sell', 'list a book', 'list my book', 'add a book', 'post a book'],
    answer:
        'To sell a book, go to Home and tap the + button. Add the title, author, price, condition, and a photo — it\'ll show up for buyers right away.',
  ),
  FaqEntry(
    keywords: ['buy', 'purchase', 'how to buy', 'how do i buy'],
    answer:
        'Just find a book you like and tap "Buy Now." You\'ll be taken to Khalti to complete payment securely.',
  ),
  FaqEntry(
    keywords: ['payment', 'khalti', 'pay', 'how do i pay'],
    answer:
        'We use Khalti for payments. When you tap "Buy Now," you\'ll be redirected to Khalti\'s checkout to pay with your Khalti wallet.',
  ),
  FaqEntry(
    keywords: ['forgot password', 'reset password', "can't login", 'cant login', 'cannot login'],
    answer:
        'No worries — tap "Forgot Password?" on the login page. We\'ll email you a 6-digit code to reset it.',
  ),
  FaqEntry(
    keywords: ['wishlist', 'save book', 'favorite'],
    answer:
        'Tap the heart icon on any book to add it to your Wishlist. You can view your saved books anytime from the Favourite tab.',
  ),
  FaqEntry(
    keywords: ['account', 'profile', 'update profile', 'change name', 'change email', 'avatar'],
    answer:
        'You can update your name, email, or profile photo from Profile > Manage Profile.',
  ),
  FaqEntry(
    keywords: ['refund', 'return', 'cancel order', 'cancel purchase'],
    answer:
        'Purchases are between buyers and sellers directly, so please reach out to the seller first. If you need more help, contact our support team.',
  ),
  FaqEntry(
    keywords: ['contact', 'support', 'help', 'human', 'real person', 'customer service'],
    answer:
        "You can reach our support team by emailing support@kitabghar.com — we're happy to help with anything I can't answer here!",
  ),
  FaqEntry(
    keywords: ['thank', 'thanks', 'thank you'],
    answer: "You're welcome! Happy to help. 📚",
  ),
  FaqEntry(
    keywords: ['bye', 'goodbye', 'see you'],
    answer: 'Bye! Come back anytime you have questions. 👋',
  ),
];

const String fallbackAnswer =
    "I'm not totally sure about that one. Try asking me about buying, selling, payments, wishlist, or your account — or email support@kitabghar.com for anything else.";

String getFaqAnswer(String message) {
  final normalized = message.toLowerCase();

  for (final entry in faqData) {
    if (entry.keywords.any((keyword) => normalized.contains(keyword))) {
      return entry.answer;
    }
  }

  return fallbackAnswer;
}

const List<String> suggestedQuestions = [
  'How do I sell a book?',
  'How do I pay?',
  'Forgot password?',
];