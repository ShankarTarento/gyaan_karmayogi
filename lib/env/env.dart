import 'package:envied/envied.dart';
import 'package:karmayogi_mobile/constants/index.dart';
part 'env.g.dart';

@Envied(path: APP_ENVIRONMENT, requireEnvFile: true)
abstract class Env {
  @EnviedField(varName: 'PORTAL_BASE_URL', obfuscate: true)
  static String portalBaseUrl = _Env.portalBaseUrl;

  @EnviedField(varName: 'BASE_URL', obfuscate: true)
  static String baseUrl = _Env.baseUrl;

  @EnviedField(varName: 'FRAC_BASE_URL', obfuscate: true)
  static String fracBaseUrl = _Env.fracBaseUrl;

  @EnviedField(varName: 'TERMS_OF_SERVICE_URL', obfuscate: true)
  static String termsOfServiceUrl = _Env.termsOfServiceUrl;

  @EnviedField(varName: 'PARICHAY_BASE_URL', obfuscate: true)
  static String parichayBaseUrl = _Env.parichayBaseUrl;

  @EnviedField(varName: 'FRAC_DICTIONARY_URL', obfuscate: true)
  static String fracDictionaryUrl = _Env.fracDictionaryUrl;

  @EnviedField(varName: 'CONFIG_URL', obfuscate: true)
  static String configUrl = _Env.configUrl;

  @EnviedField(varName: 'API_KEY', obfuscate: true)
  static String apiKey = _Env.apiKey;

  @EnviedField(varName: 'PARICHAY_CLIENT_ID', obfuscate: true)
  static String parichayClientId = _Env.parichayClientId;

  @EnviedField(varName: 'PARICHAY_CLIENT_SECRET', obfuscate: true)
  static String parichayClientSecret = _Env.parichayClientSecret;

  @EnviedField(varName: 'PARICHAY_CODE_VERIFIER', obfuscate: true)
  static String parichayCodeVerifier = _Env.parichayCodeVerifier;

  @EnviedField(varName: 'PARICHAY_KEYCLOAK_CLIENT_SECRET', obfuscate: true)
  static String parichayKeycloakSecret = _Env.parichayKeycloakSecret;

  @EnviedField(varName: 'X_CHANNEL_ID', obfuscate: true)
  static String xChannelId = _Env.xChannelId;

  @EnviedField(varName: 'HOST', obfuscate: true)
  static String host = _Env.host;

  @EnviedField(varName: 'BUCKET', obfuscate: true)
  static String bucket = _Env.bucket;

  @EnviedField(varName: 'CDN_HOST', obfuscate: true)
  static String cdnHost = _Env.cdnHost;

  @EnviedField(varName: 'CDN_BUCKET', obfuscate: true)
  static String cdnBucket = _Env.cdnBucket;

  @EnviedField(varName: 'VEGA_SOCKET_URL', obfuscate: true)
  static String vegaSocketUrl = _Env.vegaSocketUrl;

  @EnviedField(varName: 'VEGA_HINDI_SERVICE_ID', obfuscate: true)
  static String vegaHindiServiceId = _Env.vegaHindiServiceId;

  @EnviedField(varName: 'VEGA_ENGLISH_SERVICE_ID', obfuscate: true)
  static String vegaEnglishServiceId = _Env.vegaEnglishServiceId;

  @EnviedField(varName: 'VEGA_HINDI_TO_ENGLISH_SERVICE_ID', obfuscate: true)
  static String vegaHindiToEnglishServiceId = _Env.vegaHindiToEnglishServiceId;

  @EnviedField(varName: 'VEGA_ASR_API_KEY', obfuscate: true)
  static String vegaAsrApiKey = _Env.vegaAsrApiKey;

  @EnviedField(varName: 'ENTRY_PAGE_FILE_NAME', obfuscate: true)
  static String entryPageFileName = _Env.entryPageFileName;

  @EnviedField(varName: 'TELEMETRY_PDATA_ID', obfuscate: true)
  static String telemetryPdataId = _Env.telemetryPdataId;

  @EnviedField(varName: 'SOURCE_NAME', obfuscate: true)
  static String sourceName = _Env.sourceName;

  @EnviedField(varName: 'SPV_ADMIN_ROOT_ORG_ID', obfuscate: true)
  static String spvAdminRootOrgId = _Env.spvAdminRootOrgId;
}
