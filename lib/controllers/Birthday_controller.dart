import 'package:get/get.dart';

import '../db/db_helper.dart';
import '../models/birthday.dart';

class BDController extends GetxController {
  final RxList<Birthday> BDList = <Birthday>[].obs;

  Future<int> addBD({Birthday? bd}) {
    return DBHelper.insert(bd);
  }

  @override
  void onInit() {
    super.onInit();
    getBD(); // Charger initialement les données
  }

  Future<void> refreshData() async {
    // Rechargez les données depuis la base de données ou toute autre source
    // Mettez à jour les variables d'état nécessaires
    update(); // Cela déclenchera le rafraîchissement des widgets écoutant ce contrôleur
  }

  Future<void> getBD({DateTime? date}) async {
    final d = date ??
        DateTime.now().copyWith(hour: 0, minute: 0, second: 0, millisecond: 0);
    BDList.assignAll(
      (await DBHelper.query())
          .map((data) => Birthday.fromJson(data))
          .toList()
          .where(
            (t) =>
                !DateTime.parse(t.date!).isBefore(d) &&
                !DateTime.parse(t.date!).isAfter(d),
          ),
    );
  }

  void deleteBD(Birthday bd) async {
    await DBHelper.delete(bd);
    await getBD();
  }

  void deleteAllBD() async {
    await DBHelper.deleteAll();
    await getBD();
  }

  void markBDAsCompleted(int id) async {
    await DBHelper.update(id);
    await getBD();
  }
}
