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
      placeId: json['place_id'] as String?,
      placeName: json['place_name'] as String?,
      placeAddress: json['place_address'] as String?,
      placeImage: json['place_image'] as String?,
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
