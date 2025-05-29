import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class BannerModel extends Equatable {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String buttonText;
  final String offer;
  final int order;

  const BannerModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.buttonText,
    required this.offer,
    required this.order,
  });

  factory BannerModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return BannerModel(
      id: doc.id,
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      buttonText: data['buttonText'] ?? '',
      offer: data['offer'] ?? '',
      order: data['order'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'subtitle': subtitle,
      'imageUrl': imageUrl,
      'buttonText': buttonText,
      'offer': offer,
      'order': order,
    };
  }

  @override
  List<Object?> get props => [id, title, subtitle, imageUrl, buttonText, offer, order];
} 