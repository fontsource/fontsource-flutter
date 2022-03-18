import 'config.dart';
import 'gen_fonts.dart';

void main() async {
  FontsourceConfig config = await getConfig();

  genFonts(config);
}
