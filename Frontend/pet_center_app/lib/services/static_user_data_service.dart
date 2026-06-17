import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:pet_center_app/models/data_transfer/category_dto.dart';
import 'package:pet_center_app/models/data_transfer/form_template_dto.dart';
import 'package:pet_center_app/models/data_transfer/item_dto.dart';
import 'package:pet_center_app/models/data_transfer/kind_dto.dart';
import 'package:pet_center_app/models/data_transfer/listing/sub_dtos.dart';
import 'package:pet_center_app/models/data_transfer/living_condition_dto.dart';
import 'package:pet_center_app/models/data_transfer/procedure_dto.dart';
import 'package:pet_center_app/models/data_transfer/static_data_dto.dart';
import 'package:pet_center_app/models/data_transfer/user/user_response_dto.dart';
import 'package:pet_center_app/models/enums.dart';
import 'package:pet_center_app/services/category_service.dart';
import 'package:pet_center_app/services/form_template_service.dart';
import 'package:pet_center_app/services/item_service.dart';
import 'package:pet_center_app/services/kind_service.dart';
import 'package:pet_center_app/services/living_condition_service.dart';
import 'package:pet_center_app/services/procedure_service.dart';
import 'package:pet_center_app/services/user_service.dart';
import 'package:pet_center_app/utils/app_config.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/globals.dart';
import 'package:pet_center_app/utils/jwt_parser.dart';
import 'package:pet_center_app/utils/service_output.dart';

StaticDataDTO currentStaticDataVersion = StaticDataDTO();
String userStatus = '';

List<KindDTO> kinds = [];
List<CategoryDTO> categories = [];
List<ItemDTO> items = [];
UserResponseDTO? self;
List<FormTemplateDTO> templates = [];
List<LivingConditionFieldDTO> condition = [];
List<ProcedureDTO> procedures = [];
List<AnnouncementSubDTO> announcements = [];
List<ReportResponseSubDTO> reports = [];

Set<String> visitedAnnouncementIndices = {};
Set<String> visitedReportIndices = {};
Set<String> visitedListingIndices = {};

class StaticAndUserDataService {
  static Timer? _timer;
  static const int periodSeconds = 300;

  static void clearObtainedData() {
    _timer?.cancel();
    _timer = null;
    currentStaticDataVersion = StaticDataDTO();
    kinds = [];
    categories = [];
    items = [];
    templates = [];
    condition = [];
    procedures = [];
    announcements = [];
    reports = [];
    self = null;
    userStatus = '';
    visitedAnnouncementIndices = {};
    visitedReportIndices = {};
    visitedListingIndices = {};
  }

  static Future<bool> updateData() async {
    _timer?.cancel();
    _timer = null;

    bool output = true;

    apiServiceBusy.value = true;

    try {
      final response = await http.get(
        Uri.parse("${AppConfig.apiBaseUrl}/Static"),
        headers: {
          'Authorization': 'Bearer $rawToken',
          'Accept': 'application/json',
        },
      );

      final result = await ServiceOutput.fromResponse<StaticDataDTO>(
        response,
        (json) => StaticDataDTO.fromJson(json as Map<String, dynamic>),
      );

      if (result != null) {
        if (currentStaticDataVersion.kindVersion != result.kindVersion ||
            currentStaticDataVersion.breedVersion != result.breedVersion) {
          final newKinds = await KindService.getAll();
          if (newKinds != null) {
            kinds = newKinds;
            currentStaticDataVersion.kindVersion = result.kindVersion;
            currentStaticDataVersion.breedVersion = result.breedVersion;
          } else {
            output = false;
          }
        }
        if (currentStaticDataVersion.categoryVersion !=
                result.categoryVersion ||
            currentStaticDataVersion.usageVersion != result.usageVersion) {
          final newCategories = await CategoryService.getAll();
          if (newCategories != null) {
            categories = newCategories;
            currentStaticDataVersion.categoryVersion = result.categoryVersion;
            currentStaticDataVersion.usageVersion = result.usageVersion;
          } else {
            output = false;
          }
        }
        if (currentStaticDataVersion.productVersion != result.productVersion) {
          final newItems = await ItemService.getAll();
          if (newItems != null) {
            items = newItems;
            currentStaticDataVersion.productVersion = result.productVersion;
          } else {
            output = false;
          }
        }
        if (currentStaticDataVersion.announcementVersion !=
            result.announcementVersion) {
          final newAnnouncements = await UserService.getAnnouncements();
          if (newAnnouncements != null) {
            announcements = newAnnouncements;
            currentStaticDataVersion.announcementVersion =
                result.announcementVersion;
          } else {
            output = false;
          }
        }

        if (currentStaticDataVersion.reportVersion != result.reportVersion &&
            (role == Access.admin || role == Access.owner)) {
          final newReports = await UserService.getAllReports();
          if (newReports != null) {
            reports = newReports;
            currentStaticDataVersion.reportVersion = result.reportVersion;
          } else {
            output = false;
          }
        }
        if (currentStaticDataVersion.formTemplateVersion !=
            result.formTemplateVersion) {
          final newTemplates = await FormTemplateService.getAll();
          if (newTemplates != null) {
            templates = newTemplates;
            currentStaticDataVersion.formTemplateVersion =
                result.formTemplateVersion;
          } else {
            output = false;
          }
        }
        if (currentStaticDataVersion.livingConditionVersion !=
            result.livingConditionVersion) {
          final newCondition = await LivingConditionService.getAll();
          if (newCondition != null) {
            condition = newCondition;
            currentStaticDataVersion.livingConditionVersion =
                result.livingConditionVersion;
          } else {
            output = false;
          }
        }
        if (currentStaticDataVersion.procedureVersion !=
                result.procedureVersion ||
            currentStaticDataVersion.specificationVersion !=
                result.specificationVersion) {
          final newProcedures = await ProcedureService.getAll();
          if (newProcedures != null) {
            procedures = newProcedures;
            currentStaticDataVersion.procedureVersion = result.procedureVersion;
            currentStaticDataVersion.specificationVersion =
                result.specificationVersion;
          } else {
            output = false;
          }
        }

        final userResponse = await UserService.getUserStatus();
        if (userResponse == null) {
          output = false;
        }
        if (userResponse != userStatus) {
          final newSelf = await UserService.getSelf();
          if (newSelf != null) {
            self = newSelf;
            if (userResponse != null) {
              userStatus = userResponse;
            }
          } else {
            output = false;
          }
        }
      } else {
        output = false;
      }

      if (rawToken != null) {
        _timer = Timer(const Duration(seconds: periodSeconds), updateData);
      }
      apiServiceBusy.value = false;
      return output;
    } catch (ex) {
      if (rawToken != null) {
        _timer = Timer(const Duration(seconds: periodSeconds), updateData);
      }
      apiServiceBusy.value = false;
      showError(ex);
      return false;
    }
  }
}
