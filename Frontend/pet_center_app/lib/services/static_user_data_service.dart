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
List<LivingConditionEntrySubDTO> condition = [];
List<ProcedureDTO> procedures = [];
List<AnnouncementSubDTO> announcements = [];
List<ReportResponseSubDTO> reports = [];

Set<String> visitedAnnouncementIndices = {};
Set<String> visitedNotifIndices = {};
Set<String> visitedReportIndices = {};

void clearObtainedData() {
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
  visitedAnnouncementIndices = {};
  visitedNotifIndices = {};
  visitedReportIndices = {};
}

class StaticAndUserDataService {
  static Future<void> updateData() async {
    apiServiceBusy = true;
    Access role = userToken?.role ?? Access.user;
    try {
      final userResponse = await UserService.getUserStatus();
      if (userResponse != userStatus) {
        final newSelf = await UserService.getSelf();
        if (newSelf != null) {
          self = newSelf;
          if (userResponse != null) {
            userStatus = userResponse;
          }
        }
      }

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
          final newKinds = await KindService.get(false);
          if (newKinds != null) {
            kinds = newKinds;
            currentStaticDataVersion.kindVersion = result.kindVersion;
            currentStaticDataVersion.breedVersion = result.breedVersion;
          }
        }
        if (currentStaticDataVersion.categoryVersion !=
                result.categoryVersion ||
            currentStaticDataVersion.usageVersion != result.usageVersion) {
          final newCategories = await CategoryService.get(null);
          if (newCategories != null) {
            categories = newCategories;
            currentStaticDataVersion.categoryVersion = result.categoryVersion;
            currentStaticDataVersion.usageVersion = result.usageVersion;
          }
        }
        if (currentStaticDataVersion.productVersion != result.productVersion) {
          final newItems = await ItemService.get();
          if (newItems != null) {
            items = newItems;
            currentStaticDataVersion.productVersion = result.productVersion;
          }
        }
        if (currentStaticDataVersion.announcementVersion !=
            result.announcementVersion) {
          final newAnnouncements = await UserService.getAnnouncements();
          if (newAnnouncements != null) {
            announcements = newAnnouncements;
            currentStaticDataVersion.announcementVersion =
                result.announcementVersion;
          }
        }

        if (currentStaticDataVersion.reportVersion != result.reportVersion &&
            (role == Access.admin || role == Access.owner)) {
          final newReports = await UserService.getReports();
          if (newReports != null) {
            reports = newReports;
            currentStaticDataVersion.reportVersion = result.reportVersion;
          }
        }
        if (currentStaticDataVersion.formTemplateVersion !=
            result.formTemplateVersion) {
          final newTemplates = await FormTemplateService.get();
          if (newTemplates != null) {
            templates = newTemplates;
            currentStaticDataVersion.formTemplateVersion =
                result.formTemplateVersion;
          }
        }
        if (currentStaticDataVersion.livingConditionVersion !=
            result.livingConditionVersion) {
          final newCondition = await LivingConditionService.get();
          if (newCondition != null) {
            condition = newCondition;
            currentStaticDataVersion.livingConditionVersion =
                result.livingConditionVersion;
          }
        }
        if (currentStaticDataVersion.procedureVersion !=
                result.procedureVersion ||
            currentStaticDataVersion.specificationVersion !=
                result.specificationVersion) {
          final newProcedures = await ProcedureService.get();
          if (newProcedures != null) {
            procedures = newProcedures;
            currentStaticDataVersion.procedureVersion = result.procedureVersion;
            currentStaticDataVersion.specificationVersion =
                result.specificationVersion;
          }
        }
      }
      apiServiceBusy = false;
    } catch (ex) {
      apiServiceBusy = false;
      showError(ex);
    }
  }
}
