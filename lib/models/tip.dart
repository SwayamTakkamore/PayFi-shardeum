class Tip {
  final String from;
  final String to;
  final String amount;
  final String message;
  final int timestamp;
  final String? transactionHash;

  Tip({
    required this.from,
    required this.to,
    required this.amount,
    required this.message,
    required this.timestamp,
    this.transactionHash,
  });

  factory Tip.fromJson(Map<String, dynamic> json) {
    return Tip(
      from: json['from'] ?? '',
      to: json['to'] ?? '',
      amount: json['amount']?.toString() ?? '0',
      message: json['message'] ?? '',
      timestamp: json['timestamp'] ?? 0,
      transactionHash: json['transactionHash'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'from': from,
      'to': to,
      'amount': amount,
      'message': message,
      'timestamp': timestamp,
      'transactionHash': transactionHash,
    };
  }

  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);

  String get formattedAmount => '${double.parse(amount).toStringAsFixed(4)} SHM';
}
