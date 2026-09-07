import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ebook_model.dart';

enum EBookStatus { pending, approved, rejected }

class EBookSubmissionModel {
  final EBookModel ebook;
  final EBookStatus status;
  final String submittedBy;
  final DateTime submittedDate;

  EBookSubmissionModel({
    required this.ebook,
    required this.status,
    required this.submittedBy,
    required this.submittedDate,
  });
}

class EBookSubmissionsNotifier extends StateNotifier<List<EBookSubmissionModel>> {
  EBookSubmissionsNotifier() : super([]) {
    fetchCloudEBooks();
    _listenRealtime();
  }

  void _listenRealtime() {
    try {
      Supabase.instance.client
          .channel('public:EBook:realtime')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'EBook',
            callback: (_) => fetchCloudEBooks(),
          )
          .subscribe();
    } catch (_) {}
  }

  Future<void> fetchCloudEBooks() async {
    try {
      final supabaseData = await Supabase.instance.client
          .from('EBook')
          .select('*, Subject(*)');

      if (supabaseData is List && supabaseData.isNotEmpty) {
        final cloudSubmissions = supabaseData.map((item) {
          final ebook = EBookModel(
            id: item['id'].toString(),
            title: item['title'] ?? 'eBook Document',
            publicationId: 'Oxford Educational Press',
            seriesId: 'CBSE 2026',
            classId: 'Class 10',
            subjectId: item['Subject'] != null ? (item['Subject']['name'] ?? 'Mathematics') : 'Mathematics',
            coverUrl: (item['coverUrl'] != null && item['coverUrl'].toString().startsWith('http'))
                ? item['coverUrl']
                : 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400',
            fileUrl: (item['fileUrl'] != null && item['fileUrl'].toString().isNotEmpty)
                ? item['fileUrl']
                : 'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',
            status: item['isActive'] == false ? EBookAdminStatus.archived : EBookAdminStatus.published,
          );

          return EBookSubmissionModel(
            ebook: ebook,
            status: EBookStatus.approved,
            submittedBy: 'Cloud Storage',
            submittedDate: DateTime.now(),
          );
        }).toList();

        debugPrint('⚡ Loaded ${cloudSubmissions.length} eBooks directly from Supabase DB EBook table');
        state = cloudSubmissions;
      }
    } catch (e) {
      debugPrint('ℹ️ Direct Supabase eBook fetch note: $e');
    }
  }

  Future<void> saveEBookToSupabase({
    required String title,
    required String fileUrl,
    required String subjectName,
  }) async {
    try {
      final subRes = await Supabase.instance.client
          .from('Subject')
          .select()
          .ilike('name', subjectName)
          .limit(1);

      String subjectId;
      if (subRes is List && subRes.isNotEmpty) {
        subjectId = subRes[0]['id'];
      } else {
        var pubRes = await Supabase.instance.client.from('Publication').select().limit(1);
        String pubId = pubRes.isNotEmpty
            ? pubRes[0]['id']
            : (await Supabase.instance.client.from('Publication').insert({
                'name': 'General Education',
                'email': 'general@education.com',
                'mobile': '+919800000000',
                'address': 'Education Hub',
                'logoUrl': 'https://picsum.photos/200',
                'inquiryNumber': '1800123456'
              }).select().single())['id'];

        var serRes = await Supabase.instance.client.from('Series').select().limit(1);
        String serId = serRes.isNotEmpty
            ? serRes[0]['id']
            : (await Supabase.instance.client.from('Series').insert({
                'name': 'Standard Series',
                'publicationId': pubId
              }).select().single())['id'];

        var clsRes = await Supabase.instance.client.from('Class').select().limit(1);
        String clsId = clsRes.isNotEmpty
            ? clsRes[0]['id']
            : (await Supabase.instance.client.from('Class').insert({
                'name': 'Class 10',
                'seriesId': serId
              }).select().single())['id'];

        var newSub = await Supabase.instance.client.from('Subject').insert({
          'name': subjectName,
          'classId': clsId
        }).select().single();
        subjectId = newSub['id'];
      }

      await Supabase.instance.client.from('EBook').insert({
        'title': title,
        'subjectId': subjectId,
        'coverUrl': 'https://picsum.photos/300/400?random=${DateTime.now().millisecondsSinceEpoch % 1000}',
        'fileUrl': fileUrl,
        'isActive': true,
      });
      debugPrint('⚡ Direct Supabase EBook insert successful!');
      await fetchCloudEBooks();
    } catch (e) {
      debugPrint('ℹ️ Direct Supabase EBook insert note: $e');
    }
  }

  void addEBookSubmission(EBookModel ebook, {required String submittedBy, bool autoApprove = false}) {
    final submission = EBookSubmissionModel(
      ebook: ebook,
      status: autoApprove ? EBookStatus.approved : EBookStatus.pending,
      submittedBy: submittedBy,
      submittedDate: DateTime.now(),
    );
    state = [submission, ...state];
  }

  Future<void> updateEBook(EBookModel updatedEBook) async {
    state = state.map((item) {
      if (item.ebook.id == updatedEBook.id) {
        return EBookSubmissionModel(
          ebook: updatedEBook,
          status: item.status,
          submittedBy: item.submittedBy,
          submittedDate: item.submittedDate,
        );
      }
      return item;
    }).toList();

    try {
      await Supabase.instance.client
          .from('EBook')
          .update({'title': updatedEBook.title, 'fileUrl': updatedEBook.fileUrl, 'coverUrl': updatedEBook.coverUrl})
          .eq('id', updatedEBook.id);
    } catch (_) {}
  }

  Future<void> deleteEBook(String ebookId) async {
    state = state.where((item) => item.ebook.id != ebookId).toList();
    try {
      await Supabase.instance.client.from('EBook').delete().eq('id', ebookId);
    } catch (_) {}
  }

  Future<void> bulkDeleteEBooks(List<String> ebookIds) async {
    final idsSet = ebookIds.toSet();
    state = state.where((item) => !idsSet.contains(item.ebook.id)).toList();
    try {
      await Supabase.instance.client.from('EBook').delete().inFilter('id', ebookIds);
    } catch (_) {}
  }

  Future<void> bulkUpdateEBookStatus(List<String> ebookIds, EBookAdminStatus adminStatus) async {
    final idsSet = ebookIds.toSet();
    state = state.map((item) {
      if (idsSet.contains(item.ebook.id)) {
        return EBookSubmissionModel(
          ebook: item.ebook.copyWith(status: adminStatus),
          status: adminStatus == EBookAdminStatus.published ? EBookStatus.approved : item.status,
          submittedBy: item.submittedBy,
          submittedDate: item.submittedDate,
        );
      }
      return item;
    }).toList();
  }

  Future<void> toggleEBookFeatured(String ebookId) async {
    state = state.map((item) {
      if (item.ebook.id == ebookId) {
        return EBookSubmissionModel(
          ebook: item.ebook.copyWith(isFeatured: !item.ebook.isFeatured),
          status: item.status,
          submittedBy: item.submittedBy,
          submittedDate: item.submittedDate,
        );
      }
      return item;
    }).toList();
  }

  void approveEBook(String ebookId) {
    state = state.map((item) {
      if (item.ebook.id == ebookId) {
        return EBookSubmissionModel(
          ebook: item.ebook.copyWith(status: EBookAdminStatus.published),
          status: EBookStatus.approved,
          submittedBy: item.submittedBy,
          submittedDate: item.submittedDate,
        );
      }
      return item;
    }).toList();
  }

  void rejectEBook(String ebookId) {
    state = state.map((item) {
      if (item.ebook.id == ebookId) {
        return EBookSubmissionModel(
          ebook: item.ebook.copyWith(status: EBookAdminStatus.rejected),
          status: EBookStatus.rejected,
          submittedBy: item.submittedBy,
          submittedDate: item.submittedDate,
        );
      }
      return item;
    }).toList();
  }
}

final ebookSubmissionsProvider = StateNotifierProvider<EBookSubmissionsNotifier, List<EBookSubmissionModel>>((ref) {
  return EBookSubmissionsNotifier();
});
