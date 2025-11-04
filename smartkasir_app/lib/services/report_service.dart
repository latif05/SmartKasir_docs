import 'dart:convert';
import 'package:http/http.dart' as http;

class SalesReportRow {
	final String date; // YYYY-MM-DD
	final double total;
	final double profit;
	SalesReportRow({required this.date, required this.total, required this.profit});
	factory SalesReportRow.fromJson(Map<String, dynamic> json) => SalesReportRow(
		date: json['date'],
		total: (json['total'] is int) ? (json['total'] as int).toDouble() : (json['total'] as double),
		profit: (json['profit'] is int) ? (json['profit'] as int).toDouble() : (json['profit'] as double),
	);
}

class ReportService {
	static const String baseUrl = 'http://localhost:3000';

	Future<List<SalesReportRow>> getSalesReport({String? start, String? end}) async {
		final uri = Uri.parse('$baseUrl/reports/sales').replace(queryParameters: {
			if (start != null) 'start': start,
			if (end != null) 'end': end,
		});
		final res = await http.get(uri, headers: {'Accept': 'application/json'});
		if (res.statusCode != 200) {
			throw Exception('Failed to load report: ${res.statusCode}');
		}
		final List list = json.decode(res.body);
		return list.map((e) => SalesReportRow.fromJson(e)).toList();
	}
}
