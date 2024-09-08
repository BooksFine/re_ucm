import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html;
import 'package:xml/xml.dart' as xml;

import 'html_entityes_replacer.dart';

List<xml.XmlElement> htmlToFB2(String htmlString) {
  htmlString = htmlEntityesReplacer(htmlString);

  var document = html.parse(htmlString);

  var fb2Elements = <xml.XmlElement>[];

  if (document.body == null) {
    return fb2Elements;
  }

  for (var node in document.body!.nodes) {
    if (node is dom.Element) {
      for (var newNode in processNode(node)) {
        if (newNode is xml.XmlElement) {
          fb2Elements.add(newNode);
        } else {
          fb2Elements.add(xml.XmlElement(xml.XmlName('p'), [], [newNode]));
        }
      }
    }
  }

  return fb2Elements;
}

String getTagFromSource(String src) {
  return "image${src.hashCode}.png";
}

List<xml.XmlNode> processNode(dom.Node node) {
  if (node is! dom.Element) {
    return [xml.XmlText(node.text!)];
  }

  List<xml.XmlNode> children = [];
  for (var child in node.nodes) {
    var processedChild = processNode(child);
    children.addAll(processedChild);
  }

  List<xml.XmlNode> res = [];
  List<xml.XmlNode> query = [];

  for (var child in children) {
    if (child is xml.XmlElement && child.name.local == 'empty-line') {
      if (query.isNotEmpty) {
        res.addAll(getFb2Element(node, query));
        res.add(child);
        query.clear();
      }
    } else {
      query.add(child);
    }
  }
  res.addAll(getFb2Element(node, query));
  return res;
}

List<xml.XmlNode> getFb2Element(dom.Element node, List<xml.XmlNode> children) {
  switch (node.localName) {
    case 'h1':
    case 'h2':
      var title = xml.XmlElement(xml.XmlName('title'), [], children);
      return [
        xml.XmlElement(xml.XmlName('title-info'), [], [title])
      ];
    case 'br':
      return [xml.XmlElement(xml.XmlName('empty-line'), [])];
    case 'p':
      return [xml.XmlElement(xml.XmlName('p'), [], children)];
    case 'a':
      var href = node.attributes['href'];
      return [
        xml.XmlElement(
            xml.XmlName('a'),
            [xml.XmlAttribute(xml.XmlName('l:href'), href ?? 'error')],
            children)
      ];
    case 'b':
      return [xml.XmlElement(xml.XmlName('strong'), [], children)];
    case 'u':
    case 'em':
    case 'i':
      return [xml.XmlElement(xml.XmlName('emphasis'), [], children)];
    case 's':
    case 'del':
      return [xml.XmlElement(xml.XmlName('strikethrough'), [], children)];
    case 'img':
      var src = node.attributes['src'];
      var tag = getTagFromSource(src!);
      return [
        xml.XmlElement(xml.XmlName('image'), [
          xml.XmlAttribute(
            xml.XmlName('l:href'),
            "#$tag",
          )
        ]),
      ];
    case 'div':
    case 'span':
      return children;
    default:
      return [xml.XmlElement(xml.XmlName(node.localName!), [], children)];
  }
}
