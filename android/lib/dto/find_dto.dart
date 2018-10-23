import 'package:json_annotation/json_annotation.dart';

part 'find_dto.g.dart';

@JsonSerializable()
class FindDto {
  List<dynamic> content;
  int totalPages;
  int totalElements;

  FindDto();

  factory FindDto.fromJson(Map<String, dynamic> json) =>
      _$FindDtoFromJson(json);
  Map<String, dynamic> toJson() => _$FindDtoToJson(this);
}
