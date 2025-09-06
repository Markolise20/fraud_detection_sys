part of 'example.dart';

class UpdateReportStatusVariablesBuilder {
  String id;
  String status;

  final FirebaseDataConnect _dataConnect;
  UpdateReportStatusVariablesBuilder(this._dataConnect, {required  this.id,required  this.status,});
  Deserializer<UpdateReportStatusData> dataDeserializer = (dynamic json)  => UpdateReportStatusData.fromJson(jsonDecode(json));
  Serializer<UpdateReportStatusVariables> varsSerializer = (UpdateReportStatusVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<UpdateReportStatusData, UpdateReportStatusVariables>> execute() {
    return ref().execute();
  }

  MutationRef<UpdateReportStatusData, UpdateReportStatusVariables> ref() {
    UpdateReportStatusVariables vars= UpdateReportStatusVariables(id: id,status: status,);
    return _dataConnect.mutation("UpdateReportStatus", dataDeserializer, varsSerializer, vars);
  }
}

class UpdateReportStatusReportUpdate {
  String id;
  UpdateReportStatusReportUpdate.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  UpdateReportStatusReportUpdate({
    required this.id,
  });
}

class UpdateReportStatusData {
  UpdateReportStatusReportUpdate? report_update;
  UpdateReportStatusData.fromJson(dynamic json):
  
  report_update = json['report_update'] == null ? null : UpdateReportStatusReportUpdate.fromJson(json['report_update']);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (report_update != null) {
      json['report_update'] = report_update!.toJson();
    }
    return json;
  }

  UpdateReportStatusData({
    this.report_update,
  });
}

class UpdateReportStatusVariables {
  String id;
  String status;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  UpdateReportStatusVariables.fromJson(Map<String, dynamic> json):
  
  id = nativeFromJson<String>(json['id']),
  status = nativeFromJson<String>(json['status']);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['status'] = nativeToJson<String>(status);
    return json;
  }

  UpdateReportStatusVariables({
    required this.id,
    required this.status,
  });
}

