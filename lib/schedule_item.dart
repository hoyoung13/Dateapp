class ScheduleItem {
  String? placeId;
  String? placeName;
  String? placeAddress;
  String? placeImage;

  ScheduleItem({
    this.placeId,
    this.placeName,
    this.placeAddress,
    this.placeImage,
  });

  factory ScheduleItem.fromJson(Map<String, dynamic> json) {
    return ScheduleItem(
      placeId: json['placeId'] as String?,
      placeName: json['placeName'] as String?,
      placeAddress: json['placeAddress'] as String?,
      placeImage: json['placeImage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'placeId': placeId,
      'placeName': placeName,
      'placeAddress': placeAddress,
      'placeImage': placeImage,
    };
  }
}
