import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// [
// {
//     "sessionId": "do_11387417837595033617",
//     "title": "Ts Classes ",
//     "sessionHandouts": [],
//     "attachLinks": [
//         {
//             "title": "Sketch designs",
//             "url": "https://www.sketch.com/s/205d657d-1569-4ac1-a52e-7d5a88c5cd28/a/lRGA9Y7#Inspect"
//         }
//     ],
//     "facilatorIDs": [
//         "bdf547ba-79e8-49d9-9143-54353673212d",
//         "e802b792-3bec-4b2f-8c84-9c78bf7677e9"
//     ],
//     "facilatorDetails": [
//         {
//             "id": "bdf547ba-79e8-49d9-9143-54353673212d",
//             "name": "JulyTest Testjuly ",
//             "email": "JulyTest.Testjuly@yopmail.com"
//         },
//         {
//             "id": "e802b792-3bec-4b2f-8c84-9c78bf7677e9",
//             "name": "Abhishek Kamal ",
//             "email": "abhishek.c100901@gov.in"
//         }
//     ],
//     "sessionDuration": "10min",
//     "startDate": "2023-09-05",
//     "startTime": "2:00 PM",
//     "endTime": "8:00 PM",
//     "description": "Aenean et turpis at ipsum aliquam cursus. Nam enim orci, auctor eu egestas at, dapibus non ipsum. Vivamus volutpat, neque vitae tempor ornare, ex orci sodales nisl, non lobortis lacus sapien tristique nisl. Donec in nisi non sem lobortis rhoncus quis interdum massa. Fusce scelerisque nisi sed elit tempus, et sagittis lacus aliquet. Proin molestie, augue vel blandit fermentum, sapien nisi iaculis eros, ut finibus arcu tortor sed purus.",
//     "sessionType": "Offline"
// }
// ]

class SessionModel {
  final String sessionId;
  final String title;
  final List<dynamic> sessionHandouts;
  final List<AttachLink> attachLinks;
  final List<String> facilatorIDs;
  final List<FacilatorDetail> facilatorDetails;
  final String sessionDuration;
  final String startDate;
  final String startTime;
  final String endTime;
  final String description;
  final String sessionType;
  final bool markedAttendence;
  final String markedAttendenceDate;
  final String markedAttendenceTime;

  SessionModel({
    @required this.sessionId,
    @required this.title,
    @required this.sessionHandouts,
    @required this.attachLinks,
    @required this.facilatorIDs,
    @required this.facilatorDetails,
    @required this.sessionDuration,
    @required this.startDate,
    @required this.startTime,
    @required this.endTime,
    @required this.description,
    @required this.sessionType,
    @required this.markedAttendence,
    @required this.markedAttendenceDate,
    @required this.markedAttendenceTime,
  });

  static List<SessionModel> get dummySessionData {
    return List.generate(
        10,
        (index) => SessionModel(
              sessionId: 'do_11387417837595033617',
              title: 'Ts Classes $index',
              sessionHandouts: [],
              attachLinks: [
                AttachLink(
                    title: 'Sketch designs',
                    url:
                        'https://www.sketch.com/s/205d657d-1569-4ac1-a52e-7d5a88c5cd28/a/lRGA9Y7#Inspect')
              ],
              facilatorIDs: [
                "bdf547ba-79e8-49d9-9143-54353673212d",
                "e802b792-3bec-4b2f-8c84-9c78bf7677e9"
              ],
              facilatorDetails: [
                FacilatorDetail(
                    id: 'e802b792-3bec-4b2f-8c84-9c78bf7677e9',
                    email: 'Abhishek Kamal ',
                    name: 'abhishek.c100901@gov.in')
              ],
              sessionDuration: '10min',
              startDate: '2023-09-05',
              startTime: '2:00 PM',
              endTime: '8:00 PM',
              description:
                  'Aenean et turpis at ipsum aliquam cursus. Nam enim orci, auctor eu egestas at, dapibus non ipsum. Vivamus volutpat, neque vitae tempor ornare, ex orci sodales nisl, non lobortis lacus sapien tristique nisl. Donec in nisi non sem lobortis rhoncus quis interdum massa. Fusce scelerisque nisi sed elit tempus, et s',
              sessionType: 'Offline',
              markedAttendence: index % 2 == 0,
              markedAttendenceDate:
                  DateFormat('dd/MM/yyyy').format(DateTime.parse('2023-09-05')),
              markedAttendenceTime: '2:00 PM',
            ));
  }
}

class AttachLink {
  final String title;
  final String url;

  AttachLink({
    @required this.title,
    @required this.url,
  });
}

class FacilatorDetail {
  final String id;
  final String name;
  final String email;

  FacilatorDetail({
    @required this.id,
    @required this.name,
    @required this.email,
  });
}
