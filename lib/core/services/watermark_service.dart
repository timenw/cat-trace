/// 水印服务
///
/// 负责给照片添加隐形水印，用于照片溯源和版权保护。
/// 水印信息包含：
///   - 时间戳（精确到秒）
///   - 随机唯一 ID（UUID v4）
///   - 可选的自定义文本
///
/// 水印类型：
///   - 可见水印：在图片角落添加半透明文字
///   - 隐形水印：通过 LSB（最低有效位）隐写术嵌入信息，肉眼不可见
///
/// 依赖：
///   - `image` 包：图片处理
///   - `uuid` 包：生成唯一 ID
///   - `intl` 包：日期格式化

import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

/// 水印信息数据类
///
/// 包含生成水印所需的所有信息。
class WatermarkInfo {
  /// 时间戳（格式：yyyyMMdd_HHmmss）
  final String timestamp;

  /// 随机唯一 ID
  final String randomId;

  /// 完整水印文本
  final String fullText;

  /// 水印生成时间
  final DateTime generatedAt;

  const WatermarkInfo({
    required this.timestamp,
    required this.randomId,
    required this.fullText,
    required this.generatedAt,
  });

  @override
  String toString() => 'WatermarkInfo(text: $fullText, at: $generatedAt)';
}

/// 水印服务
///
/// 提供可见水印和隐形水印两种方式。
/// 使用方式：
/// ```dart
/// final service = WatermarkService();
/// final result = await service.addVisibleWatermark(imageBytes);
/// ```
class WatermarkService {
  /// UUID 生成器
  final Uuid _uuid;

  /// 水印前缀（来自 AppConstants）
  final String _prefix;

  /// 构造函数
  ///
  /// 可通过参数注入 UUID 实例，方便测试时 mock。
  WatermarkService({Uuid? uuid, String? prefix})
      : _uuid = uuid ?? const Uuid(),
        _prefix = prefix ?? AppConstants.watermarkPrefix;

  // ==================== 水印信息生成 ====================

  /// 生成水印信息
  ///
  /// 每次调用都会生成新的时间戳和随机 ID。
  /// 格式：`CT_20240615_143022_a1b2c3d4`
  WatermarkInfo generateWatermarkInfo() {
    final now = DateTime.now();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(now);
    final randomId = _uuid.v4().substring(0, 8); // 取前8位
    final fullText = '${_prefix}_${timestamp}_$randomId';

    return WatermarkInfo(
      timestamp: timestamp,
      randomId: randomId,
      fullText: fullText,
      generatedAt: now,
    );
  }

  // ==================== 可见水印 ====================

  /// 给图片添加可见水印
  ///
  /// 在图片右下角添加半透明文字水印。
  ///
  /// 参数：
  ///   - [imageBytes] 原始图片的字节数据
  ///   - [customText] 自定义水印文本（可选，默认自动生成）
  ///   - [opacity] 水印透明度（0-255，默认 80，约 30% 不透明度）
  ///
  /// 返回添加水印后的图片字节数据（JPEG 格式）。
  /// 如果处理失败，返回 null。
  Future<Uint8List?> addVisibleWatermark(
    Uint8List imageBytes, {
    String? customText,
    int opacity = 80,
  }) async {
    try {
      // 解码图片
      final image = img.decodeImage(imageBytes);
      if (image == null) return null;

      // 生成或使用自定义水印文本
      final watermarkText = customText ?? generateWatermarkInfo().fullText;

      // 根据图片大小计算字体尺寸
      final fontSize = (image.width / 25).clamp(10, 32).toInt();

      // 计算水印位置（右下角，留 10px 边距）
      final textWidth = watermarkText.length * (fontSize ~/ 2);
      final x = image.width - textWidth - 10;
      final y = image.height - fontSize - 10;

      // 绘制半透明文字水印
      img.drawString(
        image,
        watermarkText,
        font: img.arial24,
        x: x.clamp(0, image.width),
        y: y.clamp(0, image.height),
        color: img.ColorRgba8(255, 255, 255, opacity),
      );

      // 编码为 JPEG 并返回
      return Uint8List.fromList(img.encodeJpg(image, quality: 90));
    } catch (e) {
      // 图片处理失败（格式不支持、数据损坏等）
      return null;
    }
  }

  /// 给图片添加可见水印（使用 img.Image 对象）
  ///
  /// 适用于已经在内存中的 img.Image 对象，避免重复编解码。
  ///
  /// 参数：
  ///   - [image] img.Image 对象
  ///   - [customText] 自定义水印文本（可选）
  ///   - [opacity] 水印透明度（0-255）
  ///
  /// 返回是否添加成功。
  bool addVisibleWatermarkToImage(
    img.Image image, {
    String? customText,
    int opacity = 80,
  }) {
    try {
      final watermarkText = customText ?? generateWatermarkInfo().fullText;
      final fontSize = (image.width / 25).clamp(10, 32).toInt();
      final textWidth = watermarkText.length * (fontSize ~/ 2);
      final x = image.width - textWidth - 10;
      final y = image.height - fontSize - 10;

      img.drawString(
        image,
        watermarkText,
        font: img.arial24,
        x: x.clamp(0, image.width),
        y: y.clamp(0, image.height),
        color: img.ColorRgba8(255, 255, 255, opacity),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  // ==================== 隐形水印（LSB 隐写） ====================

  /// 给图片添加隐形水印（LSB 最低有效位隐写术）
  ///
  /// 将水印信息嵌入到图片像素的最低有效位中，肉眼无法察觉。
  /// 提取时需要调用 [extractInvisibleWatermark]。
  ///
  /// 原理：
  ///   1. 将水印文本转为二进制位串
  ///   2. 在每个像素的 R 通道最低有效位中嵌入一个比特
  ///   3. 嵌入前先写入 32 位长度头，方便提取时知道数据边界
  ///
  /// 参数：
  ///   - [imageBytes] 原始图片的字节数据
  ///   - [customText] 自定义水印文本（可选）
  ///
  /// 返回添加隐形水印后的图片字节数据（PNG 格式，无损压缩）。
  /// 如果处理失败或图片太小无法容纳水印，返回 null。
  Future<Uint8List?> addInvisibleWatermark(
    Uint8List imageBytes, {
    String? customText,
  }) async {
    try {
      final image = img.decodeImage(imageBytes);
      if (image == null) return null;

      final watermarkText = customText ?? generateWatermarkInfo().fullText;
      final textBytes = watermarkText.codeUnits;

      // 计算所需像素数：32位长度头 + 每个字符16位（UTF-16）
      final totalBits = 32 + (textBytes.length * 16);
      final requiredPixels = (totalBits / 3).ceil(); // 每个像素存3位（R/G/B各1位）

      if (image.width * image.height < requiredPixels) {
        // 图片太小，无法容纳水印数据
        return null;
      }

      // 将水印数据转为位串
      final bits = <bool>[];

      // 写入 32 位长度头（水印文本的字节长度）
      final length = textBytes.length;
      for (int i = 31; i >= 0; i--) {
        bits.add(((length >> i) & 1) == 1);
      }

      // 写入每个字符的 16 位数据
      for (final charCode in textBytes) {
        for (int i = 15; i >= 0; i--) {
          bits.add(((charCode >> i) & 1) == 1);
        }
      }

      // 嵌入到像素的 RGB 最低有效位
      int bitIndex = 0;
      for (int y = 0; y < image.height && bitIndex < bits.length; y++) {
        for (int x = 0; x < image.width && bitIndex < bits.length; x++) {
          final pixel = image.getPixel(x, y);

          // 修改 R 通道最低有效位
          if (bitIndex < bits.length) {
            final r = bits[bitIndex]
                ? (pixel.r.toInt() | 1)
                : (pixel.r.toInt() & 0xFE);
            image.setPixelRgba(x, y, r, pixel.g.toInt(), pixel.b.toInt(), pixel.a.toInt());
            bitIndex++;
          }

          // 修改 G 通道最低有效位
          if (bitIndex < bits.length) {
            final g = bits[bitIndex]
                ? (pixel.g.toInt() | 1)
                : (pixel.g.toInt() & 0xFE);
            image.setPixelRgba(x, y, pixel.r.toInt(), g, pixel.b.toInt(), pixel.a.toInt());
            bitIndex++;
          }

          // 修改 B 通道最低有效位
          if (bitIndex < bits.length) {
            final b = bits[bitIndex]
                ? (pixel.b.toInt() | 1)
                : (pixel.b.toInt() & 0xFE);
            image.setPixelRgba(x, y, pixel.r.toInt(), pixel.g.toInt(), b, pixel.a.toInt());
            bitIndex++;
          }
        }
      }

      // 使用 PNG 格式保存（无损压缩，保留 LSB 信息）
      return Uint8List.fromList(img.encodePng(image));
    } catch (e) {
      return null;
    }
  }

  /// 从图片中提取隐形水印
  ///
  /// 从添加了隐形水印的图片中提取嵌入的水印文本。
  ///
  /// 参数：
  ///   - [imageBytes] 包含隐形水印的图片字节数据
  ///
  /// 返回提取到的水印文本，如果提取失败返回 null。
  Future<String?> extractInvisibleWatermark(Uint8List imageBytes) async {
    try {
      final image = img.decodeImage(imageBytes);
      if (image == null) return null;

      // 提取所有像素的 RGB 最低有效位
      final bits = <bool>[];
      for (int y = 0; y < image.height; y++) {
        for (int x = 0; x < image.width; x++) {
          final pixel = image.getPixel(x, y);
          bits.add((pixel.r.toInt() & 1) == 1);
          bits.add((pixel.g.toInt() & 1) == 1);
          bits.add((pixel.b.toInt() & 1) == 1);
          // 提前终止：32位长度头 + 最多65535个字符
          if (bits.length >= 32 + 65535 * 16) break;
        }
        if (bits.length >= 32 + 65535 * 16) break;
      }

      if (bits.length < 32) return null;

      // 读取 32 位长度头
      int length = 0;
      for (int i = 0; i < 32; i++) {
        if (bits[i]) {
          length |= (1 << (31 - i));
        }
      }

      // 长度合理性检查
      if (length <= 0 || length > 65535) return null;
      if (bits.length < 32 + length * 16) return null;

      // 读取字符数据
      final charCodes = <int>[];
      for (int i = 0; i < length; i++) {
        int charCode = 0;
        for (int j = 0; j < 16; j++) {
          final bitIndex = 32 + i * 16 + j;
          if (bits[bitIndex]) {
            charCode |= (1 << (15 - j));
          }
        }
        charCodes.add(charCode);
      }

      return String.fromCharCodes(charCodes);
    } catch (e) {
      return null;
    }
  }
}
