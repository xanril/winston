//
//  replyModalPresenter.swift
//  winston
//
//  Created by Igor Marcossi on 09/08/23.
//

import SwiftUI

struct ReplyModalPresenter: ViewModifier {
  @ObservedObject var shared = ReplyModalInstance.shared
  func body(content: Content) -> some View {
    content
      .sheet(isPresented: Binding(get: { shared.isShowing == .post }, set: { if !$0 { shared.disable() } })) {
        ReplyModalPost(post: shared.subjectPost)
      }
      .sheet(isPresented: Binding(get: { shared.isShowing == .comment }, set: { if !$0 { shared.disable() } })) {
        ReplyModalComment(comment: shared.subjectComment)
      }
      .onChange(of: shared.isShowing) { newValue in
        print(newValue)
      }
  }
}

extension View {
  func replyModalPresenter() -> some View {
    self
      .modifier(ReplyModalPresenter())
  }
}

class ReplyModalInstance: ObservableObject {
  static var shared = ReplyModalInstance()
  static private let placeholderPost = Post.placeholder()
  static private let placeholderComment = Comment.placeholder()
  @Published public private(set) var subjectPost: Post = ReplyModalInstance.placeholderPost
  @Published public private(set) var subjectComment: Comment = ReplyModalInstance.placeholderComment
  @Published public private(set) var isShowing: Showing = .none { didSet { if isShowing == .none { self.clearSubjects() } } }
  
  func enable(_ subject: Subject) {
    print("asas")
    switch subject {
    case .comment(let comment):
      print("asasasasq")
      subjectComment = comment
      print("asasasasq1")
      doThisAfter(0) {
        withAnimation(spring) {
          print("asasasasq2")
          self.isShowing = .comment
          print(self.isShowing, self.subjectComment)
        }
      }
    case .post(let post):
      subjectPost = post
      doThisAfter(0) {
        withAnimation(spring) {
          self.isShowing = .post
        }
      }
    }
  }
  
  func disable() {
    print("primo")
    withAnimation(spring) { self.isShowing = .none }
    self.clearSubjects()
  }
  
  private func clearSubjects() {
    doThisAfter(0.4) { self.subjectPost = ReplyModalInstance.placeholderPost; self.subjectComment = ReplyModalInstance.placeholderComment }
  }
  
  enum Subject {
    case post(Post)
    case comment(Comment)
  }
  
  enum Showing: String {
    case post
    case comment
    case none
  }
}
