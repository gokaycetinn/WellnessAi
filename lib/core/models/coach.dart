import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

class Coach extends Equatable {
  final String id;
  final String name;
  final String coachName;
  final String title;
  final String actionLabel;
  final IconData icon;
  final String imagePath;
  final Color color;
  final Color tintColor;
  final String remoteConfigKey;
  final String? systemInstruction;

  const Coach({
    required this.id,
    required this.name,
    required this.coachName,
    required this.title,
    required this.actionLabel,
    required this.icon,
    required this.imagePath,
    required this.color,
    required this.tintColor,
    required this.remoteConfigKey,
    this.systemInstruction,
  });

  Coach copyWith({
    String? id,
    String? name,
    String? coachName,
    String? title,
    String? actionLabel,
    IconData? icon,
    String? imagePath,
    Color? color,
    Color? tintColor,
    String? remoteConfigKey,
    String? systemInstruction,
  }) {
    return Coach(
      id: id ?? this.id,
      name: name ?? this.name,
      coachName: coachName ?? this.coachName,
      title: title ?? this.title,
      actionLabel: actionLabel ?? this.actionLabel,
      icon: icon ?? this.icon,
      imagePath: imagePath ?? this.imagePath,
      color: color ?? this.color,
      tintColor: tintColor ?? this.tintColor,
      remoteConfigKey: remoteConfigKey ?? this.remoteConfigKey,
      systemInstruction: systemInstruction ?? this.systemInstruction,
    );
  }

  factory Coach.fromMap(Map<String, dynamic> map) {
    return Coach(
      id: map['id'] as String,
      name: map['name'] as String,
      coachName: map['coachName'] as String,
      title: map['title'] as String,
      actionLabel: map['actionLabel'] as String,
      icon: map['icon'] as IconData,
      imagePath: map['imagePath'] as String,
      color: map['color'] as Color,
      tintColor: map['tintColor'] as Color,
      remoteConfigKey: map['remoteConfigKey'] as String,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        coachName,
        title,
        actionLabel,
        icon,
        color,
        tintColor,
        remoteConfigKey,
        systemInstruction,
      ];
}
