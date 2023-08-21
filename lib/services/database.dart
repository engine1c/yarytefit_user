import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yarytefit/domain/user.dart';
import 'package:yarytefit/domain/workout.dart';

class DatabaseService{
  final CollectionReference _workoutCollection = FirebaseFirestore.instance.collection('workouts');
  final CollectionReference _workoutScheduleCollection = FirebaseFirestore.instance.collection('workoutSchedules');
  final CollectionReference _userDataCollection = FirebaseFirestore.instance.collection("userData");

  Future addOrUpdateWorkout(WorkoutSchedule schedule) async {
    DocumentReference workoutRef = _workoutCollection.doc(schedule.uid);

    return workoutRef.set(schedule.toWorkoutMap()).then((_) async{
      var docId = workoutRef.id;
      await _workoutScheduleCollection.doc(docId).set(schedule.toMap());
    });
  }

  Stream<List<Workout>> getWorkouts({String level, String author})
  {
    Query query;
    if(author != null)
      query = _workoutCollection.where('author', isEqualTo: author);
    else
      query = _workoutCollection.where('isOnline', isEqualTo: true);

    if(level != null)
      query = query.where('level', isEqualTo: level);

      //query = query.orderBy('createdOn', descending: true);
      //query = query.where(FieldPath.documentId, whereIn: ["KO7D0oSrOfM1Y5A0RpHG","o6Nz4MS9b39mR8RYxEmp"]);

    // return query.snapshots().map((QuerySnapshot data) =>
    //     data.docs.map((DocumentSnapshot doc) => Workout.fromJson(doc.data as Map<String, dynamic>, id: doc.id)).toList());
return query.snapshots().map((QuerySnapshot data) {
  print('Number of documents: ${data.docs.length}');
  return data.docs.map((DocumentSnapshot doc) {
    final id = doc.id;
    final data = doc.data() ;
    return Workout.fromJson(data,id: id);
  }).toList();
});
  
  }

  Future<WorkoutSchedule> getWorkout(String id) async{
    var doc = await _workoutScheduleCollection.doc(id).get();
    return WorkoutSchedule.fromJson(doc.id, doc.data() );
  }

  // User Data
  Future updateUserData(ProfUser user) async{
    final userData = user.userData.toMap();
    await _userDataCollection.doc(user.id).set(userData);
  }

  Future addUserWorkout(ProfUser user, WorkoutSchedule workout) async{
    var userWorkout = UserWorkout.fromWorkout(workout);
    user.userData.addUserWorkout(userWorkout);
    await updateUserData(user);
  }

  Stream<List<Workout>> getUserWorkouts(ProfUser user){
    var query = _workoutCollection.where(FieldPath.documentId, whereIn: user.workoutIds);

    return query.snapshots().map((QuerySnapshot data) =>
        data.docs.map((DocumentSnapshot doc) => Workout.fromJson(doc.data() , id: doc.id)).toList());
  }
}