import 'dart:async';

sealed class DataChangeEvent {
  const DataChangeEvent();
}

class PartnersChangedEvent extends DataChangeEvent {
  const PartnersChangedEvent({this.partnerId});
  final int? partnerId;
}

class WalletsChangedEvent extends DataChangeEvent {
  const WalletsChangedEvent({this.partnerId, this.walletId});
  final int? partnerId;
  final int? walletId;
}

class ProjectsChangedEvent extends DataChangeEvent {
  const ProjectsChangedEvent({this.projectId});
  final int? projectId;
}

class InstallmentsChangedEvent extends DataChangeEvent {
  const InstallmentsChangedEvent({this.installmentId});
  final int? installmentId;
}

class StaffChangedEvent extends DataChangeEvent {
  const StaffChangedEvent();
}

class DocumentsChangedEvent extends DataChangeEvent {
  const DocumentsChangedEvent();
}

/// Global hodisalar shinasi — har qanday qismda ma'lumot (hamkor, hamyon/tranzaksiya,
/// loyiha, to'lov, xodim) yaratilganda, o'zgartirilganda yoki o'chirilganda,
/// barcha tegishli ekranlar va Cubitlar darhol o'z ma'lumotlarini yangilashini ta'minlaydi.
class DataRefreshBus {
  final _controller = StreamController<DataChangeEvent>.broadcast();

  Stream<DataChangeEvent> get events => _controller.stream;

  void notifyPartnersChanged({int? partnerId}) {
    _controller.add(PartnersChangedEvent(partnerId: partnerId));
  }

  void notifyWalletsChanged({int? partnerId, int? walletId}) {
    _controller.add(WalletsChangedEvent(partnerId: partnerId, walletId: walletId));
  }

  void notifyProjectsChanged({int? projectId}) {
    _controller.add(ProjectsChangedEvent(projectId: projectId));
  }

  void notifyInstallmentsChanged({int? installmentId}) {
    _controller.add(InstallmentsChangedEvent(installmentId: installmentId));
  }

  void notifyStaffChanged() {
    _controller.add(const StaffChangedEvent());
  }

  void notifyDocumentsChanged() {
    _controller.add(const DocumentsChangedEvent());
  }

  void dispose() {
    _controller.close();
  }
}
