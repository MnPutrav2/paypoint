class OrderItemRequest {
  final String katalogId;
  final int jumlah;
  final int subtotal;

  const OrderItemRequest({
    required this.katalogId,
    required this.jumlah,
    required this.subtotal,
  });

  Map<String, dynamic> toJson() => {
    'katalog_id': katalogId,
    'jumlah': jumlah,
    'subtotal': subtotal,
  };
}

class OrderRequest {
  final String? namaCustomer;
  final String? catatan;
  final List<OrderItemRequest> orderItem;
  final int total;

  const OrderRequest({
    this.namaCustomer,
    this.catatan,
    required this.orderItem,
    required this.total,
  });

  Map<String, dynamic> toJson() => {
    'nama_customer': namaCustomer ?? '',
    'catatan': catatan ?? '',
    'order_item': orderItem.map((e) => e.toJson()).toList(),
    'total': total,
  };
}
