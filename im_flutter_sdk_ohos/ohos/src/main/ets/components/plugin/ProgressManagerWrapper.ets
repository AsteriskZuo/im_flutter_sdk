import { ChatError } from '@easemob/chatsdk';
import { FlutterPluginBinding } from '@ohos/flutter_ohos';
import Wrapper from './Wrapper';
import ChatErrorHelper from './models/ChatErrorHelper';

/**
 * Wrapper for the `com.chat.im/file_progress_manager` channel.
 *
 * Mirrors the android ProgressManager (ProgressManager.java): the channel has
 * no method keys on the Dart side (gap ledger §12 — the Flutter 4.25.0
 * ChatMethodKeys define nothing for it), so onMethodCall is not overridden and
 * any Dart-originated call falls through to the base-class notImplemented.
 * The channel exists only to push download events to Dart:
 *   - onProgress { fileId, progress }
 *   - onSuccess  { fileId, savePath }
 *   - onError    { fileId, error: { code, description } }
 * Event names and payload structures are identical to android/iOS.
 *
 * Progress registry: besides the channel emitters, this wrapper keeps a
 * per-download progress table keyed by a caller-chosen id (msg localId for
 * message attachments, fileId for group shared files). ChatManagerWrapper
 * registers a download before starting it, feeds chatsdk onProgress values
 * through updateDownloadProgress, and reads the table via
 * getDownloadProgress / hasDownloadProgressCallback when it builds the
 * chat_message channel events (onMessageProgressUpdate / onMessageSuccess /
 * onMessageError are emitted by ChatManagerWrapper, not here).
 * GroupManagerWrapper only needs the send* emitters, same as android
 * (clientWrapper.progressManager).
 *
 * Other wrappers reach this instance through the static getInstance(),
 * mirroring how android exposes it as a field on ClientWrapper.
 */
export default class ProgressManagerWrapper extends Wrapper {
  private static instance: ProgressManagerWrapper | undefined;

  /** Latest reported progress (0-100) per download id. */
  private progressTable: Map<string, number> = new Map<string, number>();

  constructor(binding: FlutterPluginBinding, channelName: string) {
    super(binding, channelName);
    ProgressManagerWrapper.instance = this;
  }

  static getInstance(): ProgressManagerWrapper | undefined {
    return ProgressManagerWrapper.instance;
  }

  /**
   * Marks a download as in-flight with progress 0. Re-registering an existing
   * id resets its progress. Key: message localId or group shared file fileId.
   */
  registerDownloadProgressCallback(id: string): void {
    this.progressTable.set(id, 0);
  }

  /** Whether a download with this id is currently registered. */
  hasDownloadProgressCallback(id: string): boolean {
    return this.progressTable.has(id);
  }

  /**
   * Records the latest progress for a registered download. Unknown ids are
   * ignored; callers should register first.
   */
  updateDownloadProgress(id: string, progress: number): void {
    if (!this.progressTable.has(id)) {
      return;
    }
    this.progressTable.set(id, progress);
  }

  /**
   * Returns the latest recorded progress for the id, or undefined when the
   * download is not registered. Query interface for ChatManagerWrapper.
   */
  getDownloadProgress(id: string): number | undefined {
    if (!this.progressTable.has(id)) {
      return undefined;
    }
    return this.progressTable.get(id);
  }

  /**
   * Removes the download from the registry. Call when the transfer finishes,
   * fails, or is superseded by a new attempt.
   */
  unregisterDownloadProgressCallback(id: string): void {
    if (this.progressTable.has(id)) {
      this.progressTable.delete(id);
    }
  }

  /** file_progress_manager event: { fileId, progress }. Mirrors android. */
  sendDownloadProgressToFlutter(fileId: string, progress: number): void {
    let data = new Map<string, Object>();
    data.set('fileId', fileId);
    data.set('progress', progress);
    this.emitEvent('onProgress', data);
  }

  /** file_progress_manager event: { fileId, savePath }. Mirrors android. */
  sendDownloadSuccessToFlutter(fileId: string, savePath: string): void {
    let data = new Map<string, Object>();
    data.set('fileId', fileId);
    data.set('savePath', savePath);
    this.emitEvent('onSuccess', data);
  }

  /**
   * file_progress_manager event: { fileId, error: { code, description } }.
   * Mirrors android sendDownloadErrorToFlutter(fileId, HyphenateException).
   */
  sendDownloadErrorToFlutter(fileId: string, e: ChatError): void {
    let data = new Map<string, Object>();
    data.set('fileId', fileId);
    data.set('error', ChatErrorHelper.toJson(e));
    this.emitEvent('onError', data);
  }

  override unRegisterEaseListener(): void {
    this.progressTable.clear();
    if (ProgressManagerWrapper.instance === this) {
      ProgressManagerWrapper.instance = undefined;
    }
  }
}
