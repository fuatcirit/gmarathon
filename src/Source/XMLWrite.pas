{
    $Id: XMLWrite.pas,v 1.1 2005/04/26 13:11:47 rjmills Exp $
    This file is part of the Free Component Library

    XML writing routines
    Copyright (c) 1999-2000 by Sebastian Guenther, sg@freepascal.org

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}

//comment block moved to remove compiler warning. RJM

{
  $Log: XMLWrite.pas,v $
  Revision 1.1  2005/04/26 13:11:47  rjmills
  *** empty log message ***

  Revision 1.1  2002/02/19 15:46:58  tmuetze
  initial checkin

  Revision 1.1.2.2  2000/07/29 14:20:54  sg
  * Modified the copyright notice to remove ambiguities

  Revision 1.1.2.1  2000/07/25 09:13:54  sg
  * Fixed some small bugs
    - some methods where 'virtual' instead of 'override' in dom.pp
    - corrections regaring wether NodeName or NodeValue is used, for
      some node types (Entity, EntityReference)

  Revision 1.1  2000/07/13 06:33:50  michael
  + Initial import

  Revision 1.9  2000/07/09 11:40:09  sg
  * ">" and "&" in text nodes are now replaced by "&gt;" and "&amp;"

  Revision 1.8  2000/06/29 08:45:32  sg
  * Now produces _much_ better output...!

  Revision 1.7  2000/04/20 14:15:45  sg
  * Minor bugfixes
  * Started support for DOM level 2
}


unit XMLWrite;

{$H+}

interface

uses Classes, DOM;

procedure WriteXMLFile(doc: TXMLDocument; const AFileName: String); overload;
procedure WriteXMLFile(doc: TXMLDocument; var AFile: Text); overload;
procedure WriteXMLFile(doc: TXMLDocument; var AStream: TStream); overload;

procedure WriteXML(Element: TDOMElement; const AFileName: String); overload;
procedure WriteXML(Element: TDOMElement; var AFile: Text); overload;
procedure WriteXML(Element: TDOMElement; var AStream: TStream); overload;


// ===================================================================

implementation

// -------------------------------------------------------------------
//   Writers for the different node types
// -------------------------------------------------------------------

procedure WriteElement(node: TDOMNode); forward;
procedure WriteAttribute(node: TDOMNode); forward;
procedure WriteText(node: TDOMNode); forward;
procedure WriteCDATA(node: TDOMNode); forward;
procedure WriteEntityRef(node: TDOMNode); forward;
procedure WriteEntity(node: TDOMNode); forward;
procedure WritePI(node: TDOMNode); forward;
procedure WriteComment(node: TDOMNode); forward;
procedure WriteDocument(node: TDOMNode); forward;
procedure WriteDocumentType(node: TDOMNode); forward;
procedure WriteDocumentFragment(node: TDOMNode); forward;
procedure WriteNotation(node: TDOMNode); forward;


type
  TWriteNodeProc = procedure(node: TDOMNode);

const
  WriteProcs: array[ELEMENT_NODE..NOTATION_NODE] of TWriteNodeProc =
    (WriteElement, WriteAttribute, WriteText, WriteCDATA, WriteEntityRef,
     WriteEntity, WritePI, WriteComment, WriteDocument, WriteDocumentType,
     WriteDocumentFragment, WriteNotation);

procedure WriteNode(node: TDOMNode);
begin
  WriteProcs[node.NodeType](node);
end;


// -------------------------------------------------------------------
//   Text file and TStream support
// -------------------------------------------------------------------

type
  TOutputProc = procedure(s: String);

var
  f: ^Text;
  stream: TStream;
  wrt, wrtln: TOutputProc;
  InsideTextNode: Boolean;


procedure Text_Write(s: String);
begin
  Write(f^, s);
end;

procedure Text_WriteLn(s: String);
begin
  WriteLn(f^, s);
end;

procedure Stream_Write(s: String);
begin
  if Length(s) > 0 then
    stream.Write(s[1], Length(s));
end;

procedure Stream_WriteLn(s: String);
begin
	if Length(s) > 0 then
		stream.Write(s[1], Length(s));
  stream.Write(#13#10, 1);
end;


// -------------------------------------------------------------------
//   Indent handling
// -------------------------------------------------------------------

var
  Indent: String;


procedure IncIndent;
begin
  Indent := Indent + '  ';
end;

procedure DecIndent;
begin
  if Length(Indent) >= 2 then
    SetLength(Indent, Length(Indent) - 2);
end;


// -------------------------------------------------------------------
//   String conversion
// -------------------------------------------------------------------

type
  TCharacters = set of Char;
  TSpecialCharCallback = procedure(c: Char);

const
  AttrSpecialChars = ['"', '&'];
  TextSpecialChars = ['<', '>', '&'];


procedure ConvWrite(const s: String; const SpecialChars: TCharacters;
  const SpecialCharCallback: TSpecialCharCallback);
var
  StartPos, EndPos: Integer;
begin
  StartPos := 1;
  EndPos := 1;
  while EndPos <= Length(s) do
  begin
    if s[EndPos] in SpecialChars then
    begin
      wrt(Copy(s, StartPos, EndPos - StartPos));
      SpecialCharCallback(s[EndPos]);
      StartPos := EndPos + 1;
    end;
    Inc(EndPos);
  end;
  if EndPos > StartPos then
    wrt(Copy(s, StartPos, EndPos - StartPos));
end;

procedure AttrSpecialCharCallback(c: Char);
begin
  if c = '"' then
    wrt('&quot;')
  else if c = '&' then
    wrt('&amp;')
  else
    wrt(c);
end;

procedure TextnodeSpecialCharCallback(c: Char);
begin
  if c = '<' then
    wrt('&lt;')
  else if c = '>' then
    wrt('&gt;')
  else if c = '&' then
    wrt('&amp;')
  else
    wrt(c);
end;


// -------------------------------------------------------------------
//   Node writers implementations
// -------------------------------------------------------------------

procedure WriteElement(node: TDOMNode);
var
  i: Integer;
  attr, child: TDOMNode;
  SavedInsideTextNode: Boolean;
  s: String;
begin
  if not InsideTextNode then
    wrt(Indent);
  wrt('<' + node.NodeName);
  for i := 0 to node.Attributes.Length - 1 do
  begin
    attr := node.Attributes.Item[i];
    wrt(' ' + attr.NodeName + '=');
    s := attr.NodeValue;
    // !!!: Replace special characters in "s" such as '&', '<', '>'
    wrt('"');
    ConvWrite(s, AttrSpecialChars, @AttrSpecialCharCallback);
    wrt('"');
  end;
  Child := node.FirstChild;
  if Child = nil then
    if InsideTextNode then
      wrt('/>')
    else
      wrtln('/>')
  else
  begin
    SavedInsideTextNode := InsideTextNode;
    if InsideTextNode or Child.InheritsFrom(TDOMText) then
      wrt('>')
    else
      wrtln('>');
    IncIndent;
    repeat
      if Child.InheritsFrom(TDOMText) then
        InsideTextNode := True;
      WriteNode(Child);
      Child := Child.NextSibling;
    until child = nil;
    DecIndent;
    if not InsideTextNode then
      wrt(Indent);
    InsideTextNode := SavedInsideTextNode;
    s := '</' + node.NodeName + '>';
    if InsideTextNode then
      wrt(s)
    else
      wrtln(s);
  end;
end;

procedure WriteAttribute(node: TDOMNode);
begin
  WriteLn('WriteAttribute');
end;

procedure WriteText(node: TDOMNode);
begin
  ConvWrite(node.NodeValue, TextSpecialChars, @TextnodeSpecialCharCallback);
end;

procedure WriteCDATA(node: TDOMNode);
begin
  if InsideTextNode then
    wrt('<![CDATA[' + node.NodeValue + ']]>')
  else
    wrtln(Indent + '<![CDATA[' + node.NodeValue + ']]>')
end;

procedure WriteEntityRef(node: TDOMNode);
begin
  wrt('&' + node.NodeName + ';');
end;

procedure WriteEntity(node: TDOMNode);
begin
  WriteLn('WriteEntity');
end;

procedure WritePI(node: TDOMNode);
begin
  WriteLn('WritePI');
end;

procedure WriteComment(node: TDOMNode);
begin
  if InsideTextNode then
    wrt('<!--' + node.NodeValue + '-->')
  else
    wrtln(Indent + '<!--' + node.NodeValue + '-->')
end;

procedure WriteDocument(node: TDOMNode);
begin
  WriteLn('WriteDocument');
end;

procedure WriteDocumentType(node: TDOMNode);
begin
  WriteLn('WriteDocumentType');
end;

procedure WriteDocumentFragment(node: TDOMNode);
begin
  WriteLn('WriteDocumentFragment');
end;

procedure WriteNotation(node: TDOMNode);
begin
  WriteLn('WriteNotation');
end;


procedure InitWriter;
begin
  InsideTextNode := False;
end;

procedure RootWriter(doc: TXMLDocument);
var
  Child: TDOMNode;
begin
  InitWriter;
  wrt('<?xml version="');
  if doc.XMLVersion <> '' then
    wrt(doc.XMLVersion)
  else
    wrt('1.0');
  wrt('"');
  if doc.Encoding <> '' then
    wrt(' encoding="' + doc.Encoding + '"');
  wrtln('?>');

  indent := '';

  child := doc.FirstChild;
  while Assigned(Child) do
  begin
    WriteNode(Child);
    Child := Child.NextSibling;
  end;
end;


// -------------------------------------------------------------------
//   Interface implementation
// -------------------------------------------------------------------

procedure WriteXMLFile(doc: TXMLDocument; const AFileName: String);
begin
  Stream := TFileStream.Create(AFileName, fmCreate);
  wrt := @Stream_Write;
  wrtln := @Stream_WriteLn;
  RootWriter(doc);
  Stream.Free;
end;

procedure WriteXMLFile(doc: TXMLDocument; var AFile: Text);
begin
  f := @AFile;
  wrt := @Text_Write;
  wrtln := @Text_WriteLn;
  RootWriter(doc);
end;

procedure WriteXMLFile(doc: TXMLDocument; var AStream: TStream);
begin
  Stream := AStream;
  wrt := @Stream_Write;
  wrtln := @Stream_WriteLn;
  RootWriter(doc);
end;


procedure WriteXML(Element: TDOMElement; const AFileName: String);
begin
  Stream := TFileStream.Create(AFileName, fmCreate);
  wrt := @Stream_Write;
  wrtln := @Stream_WriteLn;
  InitWriter;
  WriteNode(Element);
  Stream.Free;
end;

procedure WriteXML(Element: TDOMElement; var AFile: Text);
begin
  f := @AFile;
  wrt := @Text_Write;
  wrtln := @Text_WriteLn;
  InitWriter;
  WriteNode(Element);
end;

procedure WriteXML(Element: TDOMElement; var AStream: TStream);
begin
  stream := AStream;
  wrt := @Stream_Write;
  wrtln := @Stream_WriteLn;
  InitWriter;
  WriteNode(Element);
end;


end.


