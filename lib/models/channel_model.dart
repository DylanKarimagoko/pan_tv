class ChannelModel {
  String channelName;
  String description;
  String streamLabel;
  String streamUrl;
  String thumbnailUrl;
  String id;

  ChannelModel(
      {required this.channelName,
      required this.id,
      required this.description,
      required this.streamLabel,
      required this.streamUrl,
      required this.thumbnailUrl});
}
