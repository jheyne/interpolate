
library dsl.test;

import 'package:analyzer/analyzer.dart';
import 'dart:io';
import 'package:interpolate/interpolate.dart';

class DiscoveryVisitor extends GeneralizingAstVisitor {

  List<InterpolationVisitor> interpolationVisitors = new List<InterpolationVisitor>();

  @override
  void visitAnnotation(Annotation node) {
    if (node.name.name == 'BuildAccessors') {
      SymbolLiteral methodSymbol = node.arguments.arguments.first;
      String methodName = methodSymbol.components[0].value();
      print('Found BuildAccessor with method $methodSymbol');
      var visitor = new InterpolationVisitor(methodName);
      interpolationVisitors.add(visitor);
      node.parent.accept(visitor);
    }
    super.visitAnnotation(node);
  }

}

class InterpolationVisitor extends GeneralizingAstVisitor {

  final String methodName;
  InterpolationVisitor(String this.methodName) {
    print('created');
  }

  void visitInterpolationElement(InterpolationElement node) {
//    print('visitInterpolationElement');
    super.visitInterpolationElement(node);
  }

  @override
  void visitInterpolationExpression(InterpolationExpression node) {
//    print('visitInterpolationExpression');
    print(node.expression);
    super.visitInterpolationExpression(node);
  }

  @override
  void visitInterpolationString(InterpolationString node) {
    super.visitInterpolationString(node);
  }

}

void main() {
  String path = 'C:/Users/jheyne/WebstormProjects/interpolate/test/dsl_model.dart';
//  String path = '../lib/model/dsl_model.dart';
  File file = new File(path);
  CompilationUnit root = parseDartFile(file.path);
  DiscoveryVisitor visitor = new DiscoveryVisitor();
  root.accept(visitor);
  new DeclarationResolver().resolve(root, null);

//  root.accept(new InterpolationVisitor());
//  visitor.messages;
}
