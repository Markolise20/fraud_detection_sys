library dataconnect_generated;
import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'dart:convert';

part 'list_reports.dart';

part 'add_comment.dart';

part 'update_report_status.dart';

part 'get_user_reports.dart';







class ExampleConnector {
  
  
  ListReportsVariablesBuilder listReports () {
    return ListReportsVariablesBuilder(dataConnect, );
  }
  
  
  AddCommentVariablesBuilder addComment ({required String reportId, required String commentText, }) {
    return AddCommentVariablesBuilder(dataConnect, reportId: reportId,commentText: commentText,);
  }
  
  
  UpdateReportStatusVariablesBuilder updateReportStatus ({required String id, required String status, }) {
    return UpdateReportStatusVariablesBuilder(dataConnect, id: id,status: status,);
  }
  
  
  GetUserReportsVariablesBuilder getUserReports () {
    return GetUserReportsVariablesBuilder(dataConnect, );
  }
  

  static ConnectorConfig connectorConfig = ConnectorConfig(
    'us-central1',
    'example',
    'frauddetectionsys',
  );

  ExampleConnector({required this.dataConnect});
  static ExampleConnector get instance {
    return ExampleConnector(
        dataConnect: FirebaseDataConnect.instanceFor(
            connectorConfig: connectorConfig,
            sdkType: CallerSDKType.generated));
  }

  FirebaseDataConnect dataConnect;
}

