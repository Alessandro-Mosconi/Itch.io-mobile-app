import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:itchio/models/user.dart';
import 'package:logger/logger.dart';

final Logger logger = Logger(printer: PrettyPrinter());

class Game {
  int? views_count;
  String? url;
  int? id;
  String? short_text;
  int? min_price;
  double? price;
  String? type;
  bool? p_windows;
  bool? p_linux;
  bool? p_osx;
  bool? p_android;
  String? title;
  String? published_at;
  bool? can_be_bought;
  String? classification;
  String? created_at;
  bool? in_press_system;
  String? cover_url;
  int? purchases_count;
  bool? published;
  int? downloads_count;
  String? has_demo;
  User? user;
  String? still_cover_url;
  String? description;
  String? imageurl;
  String? author;
  String? currency;

  // Constructor for Game class to handle JSON data
  Game(Map<String, dynamic> data) {
    views_count = data['views_count'];
    url = data['url']??data['link'];
    id = data['id'];
    short_text = data['short_text'];
    min_price = data['min_price'];
    type = data['type'];
    p_windows = data.containsKey('p_windows') ? data['p_windows'] : (data['platforms'] != null && data['platforms'] is List && (data['platforms'] as List).contains('windows'));
    p_osx = data.containsKey('p_osx') ? data['p_osx'] : (data['platforms'] != null && data['platforms'] is List && (data['platforms'] as List).contains('osx'));
    p_android = data.containsKey('p_android') ? data['p_android'] : (data['platforms'] != null && data['platforms'] is List && (data['platforms'] as List).contains('android'));
    p_linux = data.containsKey('p_linux') ? data['p_linux'] : (data['platforms'] != null && data['platforms'] is List && (data['platforms'] as List).contains('linux'));
    title = data['title'];
    published_at = data['published_at'];
    can_be_bought = data['can_be_bought'];
    classification = data['classification'];
    created_at = data['created_at'];
    in_press_system = data['in_press_system'];
    cover_url = data['cover_url'];
    purchases_count = data['purchases_count'];
    published = data['published'];
    downloads_count = data['downloads_count'];
    still_cover_url = data['still_cover_url'];
    user = data['user'] != null ? User(data['user']) : null;
    description = data['description'];
    imageurl = data['imageurl']??data['cover_url'];
    author = data['author'];
    currency = data['currency'];

    if (data['price'] == null) {
      price = 0.0;
    } else if (data['price'] is String) {
      price = double.tryParse(data['price'].replaceAll('\$', '').trim()) ?? 0.0;
    } else if (data['price'] is double) {
      price = data['price'];
    } else if (data['price'] is int) {
      price = data['price'].toDouble();
    } else {
      logger.i(data['price'].runtimeType);
    }

  }

  String getCurrencySymbol() {
    const currencySymbols = {
      'USD': '\$',
      'EUR': '€',
      'GBP': '£',
      'JPY': '¥',
      'AUD': 'A\$',
      'CAD': 'C\$',
      'CHF': 'CHF',
      'CNY': '¥',
      'SEK': 'kr',
      'NZD': 'NZ\$',
    };

    return currencySymbols[currency] ?? '';
  }

  String getFormatPriceWithCurrency() {

    double finalPrice = price ?? 0.00;
    if (finalPrice == 0.0) {
      return 'Free';
    }
    String currencySymbol = getCurrencySymbol();

    return '${finalPrice.toStringAsFixed(2)}$currencySymbol';
  }

  Map<String, Object?> toMap() {
    return {
      'views_count': views_count,
      'url': url,
      'id': id,
      'short_text': short_text,
      'min_price': min_price,
      'price': price,
      'type': type,
      'p_windows': p_windows,
      'p_linux': p_linux,
      'p_osx': p_osx,
      'p_android': p_android,
      'title': title,
      'published_at': published_at,
      'can_be_bought': can_be_bought,
      'classification': classification,
      'created_at': created_at,
      'in_press_system': in_press_system,
      'cover_url': cover_url,
      'purchases_count': purchases_count,
      'published': published,
      'downloads_count': downloads_count,
      'has_demo': has_demo,
      'user': user?.toMap(),
      'still_cover_url': still_cover_url,
      'description': description,
      'imageurl': imageurl,
      'author': author,
      'currency': currency,
    };
  }

  getCleanDescription(){
    String tempDescription = description ?? '';
    String cleanDescription = tempDescription.replaceAllMapped(RegExp(r'<img[^>]*>'), (match) {
      return '';
    }).trim();
    return cleanDescription;
  }

  getKey(){
    String key = sha256.convert(utf8.encode(url!)).toString();
    return key;
  }
}




