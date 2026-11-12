import { TranslationLanguage } from '@easemob/chatsdk';

/**
 * Serializes chatsdk TranslationLanguage (mirrors android LanguageHelper;
 * keys match the Dart ChatTranslateLanguage.fromJson).
 */
export default class LanguageHelper {
  static toJson(language: TranslationLanguage): Map<string, Object> {
    let data = new Map<string, Object>();
    data.set('code', language.languageCode);
    data.set('name', language.languageName);
    data.set('nativeName', language.languageLocalName);
    return data;
  }

  static listToJson(languages: Array<TranslationLanguage>): Array<Map<string, Object>> {
    let list = new Array<Map<string, Object>>();
    for (let language of languages) {
      list.push(LanguageHelper.toJson(language));
    }
    return list;
  }
}
