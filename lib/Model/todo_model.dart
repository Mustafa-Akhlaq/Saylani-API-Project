class TodoModel {
  String? id;
  String? content;
  int? priority;

  TodoModel({this.id, this.content, this.priority});

  TodoModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    content = json['content'];
    priority = json['priority'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['content'] = content;
    data['priority'] = priority;
    return data;
  }
}
