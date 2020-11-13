import { MD5, enc } from 'crypto-js';
import moment from 'moment';

/**
 * ハッシュ関数
 * セキュリティ用途なし
 * https://developer.mozilla.org/ja/docs/Web/API/SubtleCrypto/digest
 * @param message string ハッシュ化したい文字列
 */
export function digestMessage (message: string) {
  return MD5(`${message}-${moment().format('YYYY-MM-DD')}`).toString(
    enc.Base64
  );
}
