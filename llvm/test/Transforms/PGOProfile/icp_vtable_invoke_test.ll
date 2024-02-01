; RUN: opt < %s -passes=pgo-icall-prom -S  | FileCheck %s --check-prefix=ICALL-FUNC
; RUN: opt < %s -passes=pgo-icall-prom -enable-vtable-cmp -icp-vtable-cmp-inst-threshold=4 -icp-vtable-cmp-inst-last-candidate-threshold=4 -icp-vtable-cmp-total-inst-threshold=4 -S | FileCheck %s --check-prefix=ICALL-VTABLE

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%class.Error = type { i8 }

@_ZTI5Error = constant { ptr, ptr } { ptr getelementptr inbounds (ptr, ptr null, i64 2), ptr null }
@_ZTV4Base = constant { [3 x ptr] } { [3 x ptr] [ptr null, ptr null, ptr @_ZN4Base10get_ticketEv] }, !type !0, !type !1
@_ZTV7Derived = constant { [3 x ptr] } { [3 x ptr] [ptr null, ptr null, ptr @_ZN7Derived10get_ticketEv] }, !type !0, !type !1, !type !2, !type !3

@.str = private unnamed_addr constant [15 x i8] c"out of tickets\00"

define i32 @_Z4testP4Base(ptr %b) personality ptr @__gxx_personality_v0 {
; ICALL-FUNC-LABEL: define i32 @_Z4testP4Base(
; ICALL-FUNC-SAME: ptr [[B:%.*]]) personality ptr @__gxx_personality_v0 {
; ICALL-FUNC-NEXT:  entry:
; ICALL-FUNC-NEXT:    [[E:%.*]] = alloca [[CLASS_ERROR:%.*]], align 8
; ICALL-FUNC-NEXT:    [[VTABLE:%.*]] = load ptr, ptr [[B]], align 8
; ICALL-FUNC-NEXT:    [[TMP0:%.*]] = tail call i1 @llvm.type.test(ptr [[VTABLE]], metadata !"_ZTS4Base")
; ICALL-FUNC-NEXT:    tail call void @llvm.assume(i1 [[TMP0]])
; ICALL-FUNC-NEXT:    [[TMP1:%.*]] = load ptr, ptr [[VTABLE]], align 8
; ICALL-FUNC-NEXT:    [[TMP2:%.*]] = icmp eq ptr [[TMP1]], @_ZN7Derived10get_ticketEv
; ICALL-FUNC-NEXT:    br i1 [[TMP2]], label [[IF_TRUE_DIRECT_TARG:%.*]], label [[IF_FALSE_ORIG_INDIRECT:%.*]], !prof [[PROF4:![0-9]+]]
; ICALL-FUNC:       if.true.direct_targ:
; ICALL-FUNC-NEXT:    [[TMP3:%.*]] = invoke i32 @_ZN7Derived10get_ticketEv(ptr [[B]])
; ICALL-FUNC-NEXT:            to label [[IF_END_ICP:%.*]] unwind label [[LPAD:%.*]]
; ICALL-FUNC:       if.false.orig_indirect:
; ICALL-FUNC-NEXT:    [[TMP4:%.*]] = icmp eq ptr [[TMP1]], @_ZN4Base10get_ticketEv
; ICALL-FUNC-NEXT:    br i1 [[TMP4]], label [[IF_TRUE_DIRECT_TARG1:%.*]], label [[IF_FALSE_ORIG_INDIRECT2:%.*]], !prof [[PROF5:![0-9]+]]
; ICALL-FUNC:       if.true.direct_targ1:
; ICALL-FUNC-NEXT:    [[TMP5:%.*]] = invoke i32 @_ZN4Base10get_ticketEv(ptr [[B]])
; ICALL-FUNC-NEXT:            to label [[IF_END_ICP3:%.*]] unwind label [[LPAD]]
; ICALL-FUNC:       if.false.orig_indirect2:
; ICALL-FUNC-NEXT:    [[CALL:%.*]] = invoke i32 [[TMP1]](ptr [[B]])
; ICALL-FUNC-NEXT:            to label [[IF_END_ICP3]] unwind label [[LPAD]]
; ICALL-FUNC:       if.end.icp3:
; ICALL-FUNC-NEXT:    [[TMP6:%.*]] = phi i32 [ [[CALL]], [[IF_FALSE_ORIG_INDIRECT2]] ], [ [[TMP5]], [[IF_TRUE_DIRECT_TARG1]] ]
; ICALL-FUNC-NEXT:    br label [[IF_END_ICP]]
; ICALL-FUNC:       if.end.icp:
; ICALL-FUNC-NEXT:    [[TMP7:%.*]] = phi i32 [ [[TMP6]], [[IF_END_ICP3]] ], [ [[TMP3]], [[IF_TRUE_DIRECT_TARG]] ]
; ICALL-FUNC-NEXT:    br label [[TRY_CONT:%.*]]
; ICALL-FUNC:       lpad:
; ICALL-FUNC-NEXT:    [[TMP8:%.*]] = landingpad { ptr, i32 }
; ICALL-FUNC-NEXT:            cleanup
; ICALL-FUNC-NEXT:            catch ptr @_ZTI5Error
; ICALL-FUNC-NEXT:    [[TMP9:%.*]] = extractvalue { ptr, i32 } [[TMP8]], 1
; ICALL-FUNC-NEXT:    [[TMP10:%.*]] = tail call i32 @llvm.eh.typeid.for(ptr nonnull @_ZTI5Error)
; ICALL-FUNC-NEXT:    [[MATCHES:%.*]] = icmp eq i32 [[TMP9]], [[TMP10]]
; ICALL-FUNC-NEXT:    br i1 [[MATCHES]], label [[CATCH:%.*]], label [[EHCLEANUP:%.*]]
; ICALL-FUNC:       catch:
; ICALL-FUNC-NEXT:    [[TMP11:%.*]] = extractvalue { ptr, i32 } [[TMP8]], 0
; ICALL-FUNC-NEXT:    [[CALL3:%.*]] = invoke i32 @_ZN5Error10error_codeEv(ptr nonnull align 1 dereferenceable(1) [[E]])
; ICALL-FUNC-NEXT:            to label [[INVOKE_CONT2:%.*]] unwind label [[LPAD1:%.*]]
; ICALL-FUNC:       invoke.cont2:
; ICALL-FUNC-NEXT:    call void @__cxa_end_catch()
; ICALL-FUNC-NEXT:    br label [[TRY_CONT]]
; ICALL-FUNC:       try.cont:
; ICALL-FUNC-NEXT:    [[RET_0:%.*]] = phi i32 [ [[CALL3]], [[INVOKE_CONT2]] ], [ [[TMP7]], [[IF_END_ICP]] ]
; ICALL-FUNC-NEXT:    ret i32 [[RET_0]]
; ICALL-FUNC:       lpad1:
; ICALL-FUNC-NEXT:    [[TMP12:%.*]] = landingpad { ptr, i32 }
; ICALL-FUNC-NEXT:            cleanup
; ICALL-FUNC-NEXT:    invoke void @__cxa_end_catch()
; ICALL-FUNC-NEXT:            to label [[INVOKE_CONT4:%.*]] unwind label [[TERMINATE_LPAD:%.*]]
; ICALL-FUNC:       invoke.cont4:
; ICALL-FUNC-NEXT:    br label [[EHCLEANUP]]
; ICALL-FUNC:       ehcleanup:
; ICALL-FUNC-NEXT:    [[LPAD_VAL7_MERGED:%.*]] = phi { ptr, i32 } [ [[TMP12]], [[INVOKE_CONT4]] ], [ [[TMP8]], [[LPAD]] ]
; ICALL-FUNC-NEXT:    resume { ptr, i32 } [[LPAD_VAL7_MERGED]]
; ICALL-FUNC:       terminate.lpad:
; ICALL-FUNC-NEXT:    [[TMP13:%.*]] = landingpad { ptr, i32 }
; ICALL-FUNC-NEXT:            catch ptr null
; ICALL-FUNC-NEXT:    [[TMP14:%.*]] = extractvalue { ptr, i32 } [[TMP13]], 0
; ICALL-FUNC-NEXT:    unreachable
;
; ICALL-VTABLE-LABEL: define i32 @_Z4testP4Base(
; ICALL-VTABLE-SAME: ptr [[B:%.*]]) personality ptr @__gxx_personality_v0 {
; ICALL-VTABLE-NEXT:  entry:
; ICALL-VTABLE-NEXT:    [[E:%.*]] = alloca [[CLASS_ERROR:%.*]], align 8
; ICALL-VTABLE-NEXT:    [[VTABLE:%.*]] = load ptr, ptr [[B]], align 8
; ICALL-VTABLE-NEXT:    [[TMP0:%.*]] = ptrtoint ptr [[VTABLE]] to i64
; ICALL-VTABLE-NEXT:    [[OFFSET_VAR:%.*]] = sub nuw i64 [[TMP0]], 16
; ICALL-VTABLE-NEXT:    [[TMP1:%.*]] = tail call i1 @llvm.type.test(ptr [[VTABLE]], metadata !"_ZTS4Base")
; ICALL-VTABLE-NEXT:    tail call void @llvm.assume(i1 [[TMP1]])
; ICALL-VTABLE-NEXT:    [[TMP2:%.*]] = icmp eq i64 ptrtoint (ptr @_ZTV7Derived to i64), [[OFFSET_VAR]]
; ICALL-VTABLE-NEXT:    br i1 [[TMP2]], label [[IF_THEN_DIRECT_CALL:%.*]], label [[IF_ELSE_ORIG_INDIRECT:%.*]], !prof [[PROF4:![0-9]+]]
; ICALL-VTABLE:       if.then.direct_call:
; ICALL-VTABLE-NEXT:    [[TMP3:%.*]] = invoke i32 @_ZN7Derived10get_ticketEv(ptr [[B]])
; ICALL-VTABLE-NEXT:            to label [[IF_END_ICP:%.*]] unwind label [[LPAD:%.*]]
; ICALL-VTABLE:       if.else.orig_indirect:
; ICALL-VTABLE-NEXT:    [[TMP4:%.*]] = icmp eq i64 ptrtoint (ptr @_ZTV4Base to i64), [[OFFSET_VAR]]
; ICALL-VTABLE-NEXT:    br i1 [[TMP4]], label [[IF_THEN_DIRECT_CALL1:%.*]], label [[IF_ELSE_ORIG_INDIRECT2:%.*]], !prof [[PROF5:![0-9]+]]
; ICALL-VTABLE:       if.then.direct_call1:
; ICALL-VTABLE-NEXT:    [[TMP5:%.*]] = invoke i32 @_ZN4Base10get_ticketEv(ptr [[B]])
; ICALL-VTABLE-NEXT:            to label [[IF_END_ICP3:%.*]] unwind label [[LPAD]]
; ICALL-VTABLE:       if.else.orig_indirect2:
; ICALL-VTABLE-NEXT:    [[TMP6:%.*]] = load ptr, ptr [[VTABLE]], align 8
; ICALL-VTABLE-NEXT:    [[CALL:%.*]] = invoke i32 [[TMP6]](ptr [[B]])
; ICALL-VTABLE-NEXT:            to label [[IF_END_ICP3]] unwind label [[LPAD]]
; ICALL-VTABLE:       if.end.icp3:
; ICALL-VTABLE-NEXT:    [[TMP7:%.*]] = phi i32 [ [[CALL]], [[IF_ELSE_ORIG_INDIRECT2]] ], [ [[TMP5]], [[IF_THEN_DIRECT_CALL1]] ]
; ICALL-VTABLE-NEXT:    br label [[IF_END_ICP]]
; ICALL-VTABLE:       if.end.icp:
; ICALL-VTABLE-NEXT:    [[TMP8:%.*]] = phi i32 [ [[TMP7]], [[IF_END_ICP3]] ], [ [[TMP3]], [[IF_THEN_DIRECT_CALL]] ]
; ICALL-VTABLE-NEXT:    br label [[TRY_CONT:%.*]]
; ICALL-VTABLE:       lpad:
; ICALL-VTABLE-NEXT:    [[TMP9:%.*]] = landingpad { ptr, i32 }
; ICALL-VTABLE-NEXT:            cleanup
; ICALL-VTABLE-NEXT:            catch ptr @_ZTI5Error
; ICALL-VTABLE-NEXT:    [[TMP10:%.*]] = extractvalue { ptr, i32 } [[TMP9]], 1
; ICALL-VTABLE-NEXT:    [[TMP11:%.*]] = tail call i32 @llvm.eh.typeid.for(ptr nonnull @_ZTI5Error)
; ICALL-VTABLE-NEXT:    [[MATCHES:%.*]] = icmp eq i32 [[TMP10]], [[TMP11]]
; ICALL-VTABLE-NEXT:    br i1 [[MATCHES]], label [[CATCH:%.*]], label [[EHCLEANUP:%.*]]
; ICALL-VTABLE:       catch:
; ICALL-VTABLE-NEXT:    [[TMP12:%.*]] = extractvalue { ptr, i32 } [[TMP9]], 0
; ICALL-VTABLE-NEXT:    [[CALL3:%.*]] = invoke i32 @_ZN5Error10error_codeEv(ptr nonnull align 1 dereferenceable(1) [[E]])
; ICALL-VTABLE-NEXT:            to label [[INVOKE_CONT2:%.*]] unwind label [[LPAD1:%.*]]
; ICALL-VTABLE:       invoke.cont2:
; ICALL-VTABLE-NEXT:    call void @__cxa_end_catch()
; ICALL-VTABLE-NEXT:    br label [[TRY_CONT]]
; ICALL-VTABLE:       try.cont:
; ICALL-VTABLE-NEXT:    [[RET_0:%.*]] = phi i32 [ [[CALL3]], [[INVOKE_CONT2]] ], [ [[TMP8]], [[IF_END_ICP]] ]
; ICALL-VTABLE-NEXT:    ret i32 [[RET_0]]
; ICALL-VTABLE:       lpad1:
; ICALL-VTABLE-NEXT:    [[TMP13:%.*]] = landingpad { ptr, i32 }
; ICALL-VTABLE-NEXT:            cleanup
; ICALL-VTABLE-NEXT:    invoke void @__cxa_end_catch()
; ICALL-VTABLE-NEXT:            to label [[INVOKE_CONT4:%.*]] unwind label [[TERMINATE_LPAD:%.*]]
; ICALL-VTABLE:       invoke.cont4:
; ICALL-VTABLE-NEXT:    br label [[EHCLEANUP]]
; ICALL-VTABLE:       ehcleanup:
; ICALL-VTABLE-NEXT:    [[LPAD_VAL7_MERGED:%.*]] = phi { ptr, i32 } [ [[TMP13]], [[INVOKE_CONT4]] ], [ [[TMP9]], [[LPAD]] ]
; ICALL-VTABLE-NEXT:    resume { ptr, i32 } [[LPAD_VAL7_MERGED]]
; ICALL-VTABLE:       terminate.lpad:
; ICALL-VTABLE-NEXT:    [[TMP14:%.*]] = landingpad { ptr, i32 }
; ICALL-VTABLE-NEXT:            catch ptr null
; ICALL-VTABLE-NEXT:    [[TMP15:%.*]] = extractvalue { ptr, i32 } [[TMP14]], 0
; ICALL-VTABLE-NEXT:    unreachable
;
entry:
  %e = alloca %class.Error
  %vtable = load ptr, ptr %b, !prof !4
  %0 = tail call i1 @llvm.type.test(ptr %vtable, metadata !"_ZTS4Base")
  tail call void @llvm.assume(i1 %0)
  %1 = load ptr, ptr %vtable
  %call = invoke i32 %1(ptr %b)
  to label %try.cont unwind label %lpad, !prof !5

lpad:
  %2 = landingpad { ptr, i32 }
  cleanup
  catch ptr @_ZTI5Error
  %3 = extractvalue { ptr, i32 } %2, 1
  %4 = tail call i32 @llvm.eh.typeid.for(ptr nonnull @_ZTI5Error)
  %matches = icmp eq i32 %3, %4
  br i1 %matches, label %catch, label %ehcleanup

catch:
  %5 = extractvalue { ptr, i32 } %2, 0

  %call3 = invoke i32 @_ZN5Error10error_codeEv(ptr nonnull align 1 dereferenceable(1) %e)
  to label %invoke.cont2 unwind label %lpad1

invoke.cont2:
  call void @__cxa_end_catch()
  br label %try.cont

try.cont:
  %ret.0 = phi i32 [ %call3, %invoke.cont2 ], [ %call, %entry ]
  ret i32 %ret.0

lpad1:
  %6 = landingpad { ptr, i32 }
  cleanup
  invoke void @__cxa_end_catch()
  to label %invoke.cont4 unwind label %terminate.lpad

invoke.cont4:
  br label %ehcleanup

ehcleanup:
  %lpad.val7.merged = phi { ptr, i32 } [ %6, %invoke.cont4 ], [ %2, %lpad ]
  resume { ptr, i32 } %lpad.val7.merged

terminate.lpad:
  %7 = landingpad { ptr, i32 }
  catch ptr null
  %8 = extractvalue { ptr, i32 } %7, 0
  unreachable
}

declare i1 @llvm.type.test(ptr, metadata)
declare void @llvm.assume(i1 noundef)
declare i32 @__gxx_personality_v0(...)
declare i32 @llvm.eh.typeid.for(ptr)

declare i32 @_ZN5Error10error_codeEv(ptr nonnull align 1 dereferenceable(1))

declare void @__cxa_end_catch()

define i32 @_ZN4Base10get_ticketEv(ptr %this) align 2 personality ptr @__gxx_personality_v0 {
entry:
  %call = tail call i32 @_Z13get_ticket_idv()
  %cmp.not = icmp eq i32 %call, -1
  br i1 %cmp.not, label %if.end, label %if.then

if.then:
  ret i32 %call

if.end:
  %exception = tail call ptr @__cxa_allocate_exception(i64 1)
  invoke void @_ZN5ErrorC1EPKci(ptr nonnull align 1 dereferenceable(1) %exception, ptr nonnull @.str, i32 1)
  to label %invoke.cont unwind label %lpad

invoke.cont:
  unreachable

lpad:
  %0 = landingpad { ptr, i32 }
  cleanup
  resume { ptr, i32 } %0
}

define i32 @_ZN7Derived10get_ticketEv(ptr %this) align 2 personality ptr @__gxx_personality_v0 {
entry:
  %call = tail call i32 @_Z13get_ticket_idv()
  %cmp.not = icmp eq i32 %call, -1
  br i1 %cmp.not, label %if.end, label %if.then

if.then:
  ret i32 %call

if.end:
  %exception = tail call ptr @__cxa_allocate_exception(i64 1)
  invoke void @_ZN5ErrorC1EPKci(ptr nonnull align 1 dereferenceable(1) %exception, ptr nonnull @.str, i32 2)
  to label %invoke.cont unwind label %lpad

invoke.cont:
  unreachable

lpad:
  %0 = landingpad { ptr, i32 }
  cleanup
  resume { ptr, i32 } %0
}

declare i32 @_Z13get_ticket_idv()
declare ptr @__cxa_allocate_exception(i64)
declare void @_ZN5ErrorC1EPKci(ptr nonnull align 1 dereferenceable(1), ptr, i32)

!0 = !{i64 16, !"_ZTS4Base"}
!1 = !{i64 16, !"_ZTSM4BaseFivE.virtual"}
!2 = !{i64 16, !"_ZTS7Derived"}
!3 = !{i64 16, !"_ZTSM7DerivedFivE.virtual"}
!4 = !{!"VP", i32 2, i64 1600, i64 13870436605473471591, i64 900, i64 1960855528937986108, i64 700}
!5 = !{!"VP", i32 0, i64 1600, i64 14811317294552474744, i64 900, i64 9261744921105590125, i64 700}
