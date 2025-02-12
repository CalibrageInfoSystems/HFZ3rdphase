import 'dart:convert';

import 'package:custom_date_range_picker/custom_date_range_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hairfixingzone/AgentBranchModel.dart';

import 'package:hairfixingzone/BranchModel.dart';
import 'package:hairfixingzone/Common/common_styles.dart';
import 'package:hairfixingzone/CommonUtils.dart';
import 'package:hairfixingzone/MyAppointment_Model.dart';

import 'package:hairfixingzone/api_config.dart';
import 'package:hairfixingzone/viewconsulationlistscreen.dart';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'AgentBranchesModel.dart';

class ViewConsultation extends StatefulWidget {
  final int agentId;
  const ViewConsultation({super.key, required this.agentId});

  @override
  State<ViewConsultation> createState() => _ViewConsultationState();
}

class _ViewConsultationState extends State<ViewConsultation> {
  TextEditingController fromToDates = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;
  late Future<List<AgentBranchModel>> agentData;

  @override
  void initState() {
    super.initState();
    print('_____${widget.agentId}');
    agentData = getBranches(widget.agentId);
  }

  Future<List<AgentBranchModel>> getBranches(int userId) async {
    String apiUrl = '$baseUrl$GetBranchByUserId$userId/null';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      print('apiUrl: $apiUrl');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> listresult = data['listResult'];
        List<AgentBranchModel> result =
            listresult.map((e) => AgentBranchModel.fromJson(e)).toList();
        return result;
      } else {
        print('Request failed with status: ${response.statusCode}');
        throw Exception('Request failed with status: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
      // throw Exception('Error: $error');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: CommonStyles.whiteColor,
        //    appBar: _appBar(context),
        body: FutureBuilder(
          future: agentData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator.adaptive(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(snapshot.error.toString()),
              );
            } else {
              List<AgentBranchModel> data = snapshot.data!;
              if (data.isEmpty) {
                return const Center(
                  child: Text('No Branches are Found!'),
                );
              } else {
                return Container(
                  child: ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      AgentBranchModel agent = data[index];
                      String? imageUrl = agent.imageName;
                      if (imageUrl == null || imageUrl.isEmpty) {
                        imageUrl = 'assets/top_image.png';
                      }
                      return ViewConsulatationBranchTemplate(
                        startDate: startDate,
                        endDate: endDate,
                        agent: agent,
                        imageUrl: imageUrl,
                        agentId: widget.agentId,
                      );
                    },
                  ),
                );
              }
            }
          },
        ),
      ),
    );
  }
}

class ViewConsulatationBranchTemplate extends StatelessWidget {
  final AgentBranchModel agent;
  final String imageUrl;
  final int agentId;
  final DateTime? startDate;
  final DateTime? endDate;

  const ViewConsulatationBranchTemplate(
      {super.key,
      required this.agent,
      required this.imageUrl,
      required this.agentId,
      this.startDate,
      this.endDate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      width: MediaQuery.of(context).size.width,
      child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => viewconsulationlistscreen(
                        branchid: agent.id!,
                        fromdate: '$startDate',
                        todate: '$endDate',
                        agent: agent,
                        userid: agentId,
                      )),
            );
          },
          child: Container(
            height: MediaQuery.of(context).size.height / 10,
            width: MediaQuery.of(context).size.width,
            // decoration: BoxDecoration(
            //   border: Border.all(color: Color(0xFF662e91), width: 1.0),
            //   borderRadius: BorderRadius.circular(10.0),
            // ),
            decoration: BoxDecoration(
              color: Color(0xFFdbeaff),
              borderRadius: BorderRadius.circular(10.0),
              // borderRadius: BorderRadius.circular(30), //border corner radius
              // boxShadow: [
              //   BoxShadow(
              //     color: Color(0xFF11528f).withOpacity(0.2), //color of shadow
              //     spreadRadius: 2, //spread radius
              //     blurRadius: 4, // blur radius
              //     offset: Offset(0, 2), // changes position of shadow
              //   ),
              // ],
            ),
            child: Row(
              children: [
                Container(
                  margin: EdgeInsets.only(
                      top: 10.0, left: 10.0, right: 10.0, bottom: 10.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      width: 2.5,
                    ),
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(13.0),
                    child: Image.network(
                      imageUrl.isNotEmpty
                          ? imageUrl
                          : 'https://example.com/placeholder-image.jpg',
                      width: 65,
                      height: 60,
                      fit: BoxFit.fill,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;

                        return Center(
                            child: CircularProgressIndicator.adaptive());
                      },
                    ),
                  ),
                  width: 65,
                  height: 60,
                ),
                // width: MediaQuery.of(context).size.width / 4,

                Container(
                  // height: MediaQuery.of(context).size.height / 4 / 2,

                  width: MediaQuery.of(context).size.width / 1.5,
                  padding: EdgeInsets.only(top: 7),
                  // width: MediaQuery.of(context).size.width / 4,
                  child: Column(
                    //  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${agent.name}',
                        style: CommonUtils.txSty_18b_fb,
                        //  style:  GoogleFonts.outfit(fontWeight: FontWeight.w700,fontSize: 18,color: Color(0xFF11528f)),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text('${agent.address}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: CommonStyles.txSty_12b_f5),
                    ],
                  ),
                )
              ],
            ),
          )
          // Container(
          //   height: MediaQuery.of(context).size.height / 8,
          //   width: MediaQuery.of(context).size.width,
          //   // decoration: BoxDecoration(
          //   //   border: Border.all(color: Color(0xFF662e91), width: 1.0),
          //   //   borderRadius: BorderRadius.circular(10.0),
          //   // ),
          //   decoration: BoxDecoration(
          //     color: Colors.white,
          //     borderRadius: BorderRadius.circular(10.0),
          //     // borderRadius: BorderRadius.circular(30), //border corner radius
          //     boxShadow: [
          //       BoxShadow(
          //         color:
          //         const Color(0xFF960efd).withOpacity(0.2), //color of shadow
          //         spreadRadius: 2, //spread radius
          //         blurRadius: 4, // blur radius
          //         offset: const Offset(0, 2), // changes position of shadow
          //       ),
          //     ],
          //   ),
          //   child: Row(
          //     children: [
          //       Padding(
          //         padding: const EdgeInsets.only(left: 15.0, top: 0.0),
          //         child: SizedBox(
          //           width: MediaQuery.of(context).size.width / 3,
          //           height: 65,
          //           // decoration: BoxDecoration(
          //           //   borderRadius: BorderRadius.circular(10.0),
          //           //   border: Border.all(
          //           //     color: Color(0xFF9FA1EE),
          //           //     width: 3.0,
          //           //   ),
          //           // ),
          //           child: ClipRRect(
          //             borderRadius: BorderRadius.circular(8.0),
          //             child: Image.network(
          //               imageUrl.isNotEmpty
          //                   ? imageUrl
          //                   : 'https://example.com/placeholder-image.jpg',
          //               fit: BoxFit.cover,
          //               height: MediaQuery.of(context).size.height / 4 / 2,
          //               width: MediaQuery.of(context).size.width / 3.2,
          //               errorBuilder: (context, error, stackTrace) {
          //                 return Image.asset(
          //                   'assets/hairfixing_logo.png', // Path to your PNG placeholder image
          //                   fit: BoxFit.cover,
          //                   height: MediaQuery.of(context).size.height / 4 / 2,
          //                   width: MediaQuery.of(context).size.width / 3.2,
          //                 );
          //               },
          //             ),
          //           ),
          //         ),
          //       ),
          //       const SizedBox(
          //         width: 5,
          //       ),
          //       Padding(
          //           padding: const EdgeInsets.only(left: 5.0, top: 10.0),
          //           child: SizedBox(
          //             width: MediaQuery.of(context).size.width / 2.5,
          //             //    padding: EdgeInsets.only(top: 7),
          //             // width: MediaQuery.of(context).size.width / 4,
          //             child: Column(
          //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //               crossAxisAlignment: CrossAxisAlignment.start,
          //               children: [
          //                 Text(
          //                   branchnames.name,
          //                   style: const TextStyle(
          //                     color: Color(0xFF0f75bc),
          //                     fontSize: 14.0,
          //                     fontWeight: FontWeight.w600,
          //                   ),
          //                 ),
          //                 const SizedBox(
          //                   height: 5,
          //                 ),
          //                 Text(
          //                   branchnames.address,
          //                   style: const TextStyle(
          //                       color: Colors.black,
          //                       fontSize: 12.0,
          //                       fontWeight: FontWeight.w600),
          //                   maxLines: 3,
          //                   overflow: TextOverflow.ellipsis,
          //                 ),
          //               ],
          //             ),
          //           ))
          //     ],
          //   ),
          // ),
          ),
    );
    // return
    //   Container(
    //   padding: const EdgeInsets.all(10),
    //   width: MediaQuery.of(context).size.width,
    //   child: GestureDetector(
    //       onTap: () {
    //         Navigator.push(
    //           context,
    //           MaterialPageRoute(
    //               builder: (context) => viewconsulationlistscreen(
    //                     branchid: agent.id!,
    //                     fromdate: '$startDate',
    //                     todate: '$endDate',
    //                     agent: agent,
    //                     userid: agentId,
    //                   )),
    //         );
    //       },
    //       child: Container(
    //         height: MediaQuery.of(context).size.height / 10,
    //         width: MediaQuery.of(context).size.width,
    //         // decoration: BoxDecoration(
    //         //   border: Border.all(color: Color(0xFF662e91), width: 1.0),
    //         //   borderRadius: BorderRadius.circular(10.0),
    //         // ),
    //         // decoration: BoxDecoration(
    //         //   color: Colors.white,
    //         //   borderRadius: BorderRadius.circular(10.0),
    //         //   // borderRadius: BorderRadius.circular(30), //border corner radius
    //
    //         // ),
    //         padding: const EdgeInsets.all(10),
    //         decoration: BoxDecoration(
    //           gradient: const LinearGradient(
    //             colors: [
    //               Color(0xFFFFFFFF),
    //               Color(0xFFFFFFFF),
    //             ],
    //             begin: Alignment.centerLeft,
    //             end: Alignment.centerRight,
    //           ),
    //           border: Border.all(
    //             color: Colors.grey,
    //             //  color: const Color(0xFF8d97e2), // Add your desired border color here
    //             width: 1.0, // Set the border width
    //           ),
    //           borderRadius: BorderRadius.circular(
    //               10.0), // Optional: Add border radius if needed
    //         ),
    //         child: Row(
    //           children: [
    //             Container(
    //               clipBehavior: Clip.antiAlias,
    //               // padding: const EdgeInsets.all(10),
    //               decoration: BoxDecoration(
    //                 borderRadius: BorderRadius.circular(10.0),
    //                 color: Colors.grey,
    //               ),
    //               child: Image.network(
    //                 imageUrl.isNotEmpty
    //                     ? imageUrl
    //                     : 'https://example.com/placeholder-image.jpg',
    //                 fit: BoxFit.cover,
    //                 height: MediaQuery.of(context).size.height / 4 / 2,
    //                 width: MediaQuery.of(context).size.width / 3.2,
    //                 errorBuilder: (context, error, stackTrace) {
    //                   return Image.asset(
    //                     'assets/hairfixing_logo.png', // Path to your PNG placeholder image
    //                     fit: BoxFit.cover,
    //                     height: MediaQuery.of(context).size.height / 4 / 2,
    //                     width: MediaQuery.of(context).size.width / 3.2,
    //                   );
    //                 },
    //               ),
    //             ),
    //             const SizedBox(width: 12),
    //             Container(
    //               // height: MediaQuery.of(context).size.height / 4 / 2,
    //               alignment: Alignment.centerLeft,
    //               width: MediaQuery.of(context).size.width / 2.2,
    //               // width: MediaQuery.of(context).size.width / 4,
    //               child: Column(
    //                 //  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //                 crossAxisAlignment: CrossAxisAlignment.start,
    //                 children: [
    //                   Text(
    //                     agent.name,
    //                     style: const TextStyle(
    //                       color: Color(0xFF0f75bc),
    //                       fontSize: 14.0,
    //                       fontFamily: "Outfit",
    //                       fontWeight: FontWeight.w600,
    //                     ),
    //                   ),
    //                   const SizedBox(
    //                     height: 5,
    //                   ),
    //                   Text(agent.address,
    //                       maxLines: 2,
    //
    //                       overflow: TextOverflow.ellipsis,
    //                       style: CommonStyles.txSty_12b_f5),
    //                 ],
    //               ),
    //             )
    //           ],
    //         ),
    //       )),
    // );
  }
}
