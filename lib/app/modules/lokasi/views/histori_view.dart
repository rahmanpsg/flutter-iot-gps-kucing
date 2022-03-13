import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:iot_gps_kucing/app/controllers/lokasi_controller.dart';
import 'package:iot_gps_kucing/app/themes/app_colors.dart';
import 'package:iot_gps_kucing/app/themes/app_text.dart';
import 'package:responsive_table/responsive_table.dart';

class HistoriView extends GetView<LokasiController> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        // mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.all(12),
            width: double.infinity,
            // height: 1000,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.74,
            ),
            decoration: BoxDecoration(
              color: secondaryColor,
              shape: BoxShape.rectangle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  offset: Offset(-5, 5), // changes position of shadow
                ),
              ],
            ),
            child: Obx(
              () => controller.loading.value
                  ? Center(child: CircularProgressIndicator())
                  : ResponsiveDatatable(
                      title: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Tabel Histori Lokasi",
                          style: kTabStyle,
                        ),
                      ),
                      actions: [
                        TextButton.icon(
                          onPressed: controller.listLokasi.isEmpty
                              ? null
                              : controller.exportToExcel,
                          icon: Icon(
                            Icons.import_export,
                            color: Colors.white,
                          ),
                          label: Text(
                            "Export Data",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                controller.listLokasi.isEmpty
                                    ? Colors.greenAccent.withOpacity(.7)
                                    : Colors.greenAccent),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: controller.listLokasi.isEmpty
                              ? null
                              : controller.resetListLokasi,
                          icon: Icon(
                            Icons.clear_all,
                            color: Colors.white,
                          ),
                          label: Text(
                            "Reset Data",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                controller.listLokasi.isEmpty
                                    ? dangerColor.withOpacity(.5)
                                    : dangerColor),
                          ),
                        ),
                      ],
                      headers: controller.headerDataTable,
                      reponseScreenSizes: [ScreenSize.xs],
                      source: controller.listLokasi
                          .asMap()
                          .entries
                          .map(
                            (entry) => {
                              'no': entry.key + 1,
                              ...entry.value.toJson(),
                            },
                          )
                          .toList(),
                      // source: controller.source.value,
                      selecteds: [],
                      showSelect: false,
                      autoHeight: false,
                      footers: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: Text(
                              "Total Data : ${controller.listLokasi.length}"),
                        ),
                      ]),
            ),
          )
        ],
      ),
    );
  }
}
