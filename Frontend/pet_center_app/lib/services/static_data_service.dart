import 'package:http/http.dart' as http;
import 'package:pet_center_app/models/data_transfer/category_dto.dart';
import 'package:pet_center_app/models/data_transfer/form_template_dto.dart';
import 'package:pet_center_app/models/data_transfer/item_dto.dart';
import 'package:pet_center_app/models/data_transfer/kind_dto.dart';
import 'package:pet_center_app/models/data_transfer/living_condition_dto.dart';
import 'package:pet_center_app/models/data_transfer/procedure_dto.dart';
import 'package:pet_center_app/models/data_transfer/static_data_dto.dart';
import 'package:pet_center_app/models/data_transfer/user/user_response_dto.dart';
import 'package:pet_center_app/services/category_service.dart';
import 'package:pet_center_app/services/form_template_service.dart';
import 'package:pet_center_app/services/item_service.dart';
import 'package:pet_center_app/services/kind_service.dart';
import 'package:pet_center_app/services/living_condition_service.dart';
import 'package:pet_center_app/services/procedure_service.dart';
import 'package:pet_center_app/services/user_service.dart';
import 'package:pet_center_app/utils/app_config.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/jwt_parser.dart';
import 'package:pet_center_app/utils/service_output.dart';

StaticDataDTO currentStaticDataVersion = StaticDataDTO();

List<KindDTO> kinds = [];
List<CategoryDTO> categories = [];
List<ItemDTO> items = [];
UserResponseDTO? self;
List<FormTemplateDTO> templates = [];
List<LivingConditionEntrySubDTO> condition = [];
List<ProcedureDTO> procedures = [];

Set<String> visitedNotifIndices = {};
Set<String> visitedReportIndices = {};

class StaticDataService {
  static Future<void> updateStaticData() async {
    try {
      final response = await http.get(
        Uri.parse("${AppConfig.apiBaseUrl}/Static"),
        headers: {'Authorization': 'Bearer $rawToken'},
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
          final newSelf = await UserService.getSelf();
          if (newSelf != null) {
            self = newSelf;
            currentStaticDataVersion.announcementVersion =
                result.announcementVersion;
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
    } catch (ex) {
      showError(ex);
    }
  }
}
