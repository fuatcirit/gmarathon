{
  $Log: dom.pas,v $
  Revision 1.1  2005/04/26 13:11:47  rjmills
  *** empty log message ***

  Revision 1.2  2003/11/05 05:10:59  figmentsoft
  Code cleanup.
  Added Result variable to CloneNode() and RemoveChild() functions.

  Revision 1.1  2002/02/19 15:46:58  tmuetze
  initial checkin

  Revision 1.1.2.2  2000/07/29 14:20:54  sg
  * Modified the copyright notice to remove ambiguities

  Revision 1.1.2.1  2000/07/25 09:13:54  sg
  * Fixed some small bugs
    - some methods where 'virtual' instead of 'override' in dom.pp
    - corrections regaring wether NodeName or NodeValue is used, for
      some node types (Entity, EntityReference)

  Revision 1.1  2000/07/13 06:33:49  michael
  + Initial import

  Revision 1.16  2000/07/09 11:38:33  sg
  * Fixed TDOMNode_WithChildren.RemoveNode for the case when the node to be
    removed is the first child node.

  Revision 1.15  2000/06/29 08:45:05  sg
  * RemoveAttributeNode bugfix

  Revision 1.14  2000/05/04 18:24:22  sg
  * Bugfixes: In some cases the DOM node tree was invalid
  * Simplifications
  * Minor optical improvements

  Revision 1.13  2000/04/20 14:15:45  sg
  * Minor bugfixes
  * Started support for DOM level 2

  Revision 1.12  2000/02/13 10:03:31  sg
  * Hopefully final fix for TDOMDocument.DocumentElement:
    - Reading this property always delivers the first element in the document
    - Removed SetDocumentElement. Use "AppendChild" or one of the other
      generic methods for TDOMNode instead.

  Revision 1.11  2000/01/30 22:18:16  sg
  * Fixed memory leaks, all nodes are now freed by their parent
  * Many cosmetic changes

  Revision 1.10  2000/01/07 01:24:34  peter
    * updated copyright to 2000

  Revision 1.9  2000/01/06 23:55:22  peter
    * childnodes property as that is used instead of getchildnodes
      in the apps

  Revision 1.8  2000/01/06 01:20:36  peter
    * moved out of packages/ back to topdir

  Revision 1.1  2000/01/03 19:33:11  peter
    * moved to packages dir

  Revision 1.6  1999/12/05 22:00:10  sg
  * Bug workaround for problem with "exit(<some string type>)"

  Revision 1.5  1999/07/12 12:19:49  michael
  + More fixes from Sebastian Guenther

  Revision 1.4  1999/07/11 20:20:11  michael
  + Fixes from Sebastian Guenther

  Revision 1.3  1999/07/10 21:48:26  michael
  + Made domelement constructor virtual, needs overriding in thtmlelement

  Revision 1.2  1999/07/09 21:05:49  michael
  + fixes from Guenther Sebastian

  Revision 1.1  1999/07/09 08:35:09  michael
  + Initial implementation by Sebastian Guenther

}

unit DOM;

interface

uses SysUtils, Classes;

type
// -------------------------------------------------------
//   DOMString
// -------------------------------------------------------

	DOMString = String;  // !!!: should be WideString as soon as this is supported by the compiler


// -------------------------------------------------------
//   DOMException
// -------------------------------------------------------


const

	// DOM Level 1 exception codes:

	INDEX_SIZE_ERR              = 1;  // index or size is negative, or greater than the allowed value
	DOMSTRING_SIZE_ERR          = 2;  // Specified range of text does not fit into a DOMString
	HIERARCHY_REQUEST_ERR       = 3;  // node is inserted somewhere it does not belong
	WRONG_DOCUMENT_ERR          = 4;  // node is used in a different document than the one that created it (that does not support it)
	INVALID_CHARACTER_ERR       = 5;  // invalid or illegal character is specified, such as in a name
	NO_DATA_ALLOWED_ERR         = 6;  // data is specified for a node which does not support data
	NO_MODIFICATION_ALLOWED_ERR = 7;  // an attempt is made to modify an object where modifications are not allowed
	NOT_FOUND_ERR               = 8;  // an attempt is made to reference a node in a context where it does not exist
	NOT_SUPPORTED_ERR           = 9;  // implementation does not support the type of object requested
	INUSE_ATTRIBUTE_ERR         = 10; // an attempt is made to add an attribute that is already in use elsewhere

	// DOM Level 2 exception codes:

	INVALID_STATE_ERR       = 11; // an attempt is made to use an object that is not, or is no longer, usable
	SYNTAX_ERR          = 12; // invalid or illegal string specified
	INVALID_MODIFICATION_ERR    = 13; // an attempt is made to modify the type of the underlying object
	NAMESPACE_ERR               = 14; // an attempt is made to create or change an object in a way which is incorrect with regard to namespaces
	INVALID_ACCESS_ERR          = 15; // parameter or operation is not supported by the underlying object


type

	EDOMError = class(Exception)
	protected
		constructor Create(ACode: Integer; const ASituation: String);
	public
		Code: Integer;
	end;

	EDOMIndexSize = class(EDOMError)
	public
		constructor Create(const ASituation: String);
	end;

	EDOMHierarchyRequest = class(EDOMError)
	public
		constructor Create(const ASituation: String);
	end;

	EDOMWrongDocument = class(EDOMError)
	public
    constructor Create(const ASituation: String);
  end;

  EDOMNotFound = class(EDOMError)
  public
    constructor Create(const ASituation: String);
  end;

  EDOMNotSupported = class(EDOMError)
  public
    constructor Create(const ASituation: String);
  end;

  EDOMInUseAttribute = class(EDOMError)
	public
    constructor Create(const ASituation: String);
  end;

  EDOMInvalidState = class(EDOMError)
  public
    constructor Create(const ASituation: String);
  end;

  EDOMSyntax = class(EDOMError)
  public
    constructor Create(const ASituation: String);
  end;

  EDOMInvalidModification = class(EDOMError)
  public
    constructor Create(const ASituation: String);
  end;

  EDOMNamespace = class(EDOMError)
  public
    constructor Create(const ASituation: String);
  end;

	EDOMInvalidAccess = class(EDOMError)
  public
    constructor Create(const ASituation: String);
  end;


// -------------------------------------------------------
//   Node
// -------------------------------------------------------

const

  ELEMENT_NODE = 1;
  ATTRIBUTE_NODE = 2;
  TEXT_NODE = 3;
	CDATA_SECTION_NODE = 4;
	ENTITY_REFERENCE_NODE = 5;
	ENTITY_NODE = 6;
	PROCESSING_INSTRUCTION_NODE = 7;
	COMMENT_NODE = 8;
	DOCUMENT_NODE = 9;
	DOCUMENT_TYPE_NODE = 10;
	DOCUMENT_FRAGMENT_NODE = 11;
	NOTATION_NODE = 12;

type

	TDOMImplementation = class;
	TDOMDocumentFragment = class;
	TDOMDocument = class;
	TDOMNode = class;
	TDOMNodeList = class;
	TDOMNamedNodeMap = class;
	TDOMCharacterData = class;
	TDOMAttr = class;
	TDOMElement = class;
	TDOMText = class;
	TDOMComment = class;
	TDOMCDATASection = class;
	TDOMDocumentType = class;
	TDOMNotation = class;
	TDOMEntity = class;
	TDOMEntityReference = class;
	TDOMProcessingInstruction = class;

	TRefClass = class
	protected
		RefCounter: LongInt;
	public
		constructor Create;
		function AddRef: LongInt; virtual;
		function Release: LongInt; virtual;
	end;

	TDOMNode = class
	protected
		FNodeName, FNodeValue: DOMString;
    FNodeType: Integer;
    FParentNode: TDOMNode;
    FPreviousSibling, FNextSibling: TDOMNode;
    FOwnerDocument: TDOMDocument;

    function  GetNodeValue: DOMString; virtual;
    procedure SetNodeValue(AValue: DOMString); virtual;
		function  GetFirstChild: TDOMNode; virtual;
    function  GetLastChild: TDOMNode; virtual;
    function  GetAttributes: TDOMNamedNodeMap; virtual;

    constructor Create(AOwner: TDOMDocument);
  public
    // Free NodeList with TDOMNodeList.Release!
    function GetChildNodes: TDOMNodeList; virtual;

    property NodeName: DOMString read FNodeName;
    property NodeValue: DOMString read GetNodeValue write SetNodeValue;
    property NodeType: Integer read FNodeType;
    property ParentNode: TDOMNode read FParentNode;
    property FirstChild: TDOMNode read GetFirstChild;
    property LastChild: TDOMNode read GetLastChild;
    property ChildNodes: TDOMNodeList read GetChildNodes;
    property PreviousSibling: TDOMNode read FPreviousSibling;
    property NextSibling: TDOMNode read FNextSibling;
    property Attributes: TDOMNamedNodeMap read GetAttributes;
    property OwnerDocument: TDOMDocument read FOwnerDocument;

    function InsertBefore(NewChild, RefChild: TDOMNode): TDOMNode; virtual;
    function ReplaceChild(NewChild, OldChild: TDOMNode): TDOMNode; virtual;
    function RemoveChild(OldChild: TDOMNode): TDOMNode; virtual;
    function AppendChild(NewChild: TDOMNode): TDOMNode; virtual;
		function HasChildNodes: Boolean; virtual;
		function CloneNode(deep: Boolean): TDOMNode; overload;

		// Extensions to DOM interface:
		function CloneNode(deep: Boolean; ACloneOwner: TDOMDocument): TDOMNode; overload; virtual;
    function FindNode(const ANodeName: DOMString): TDOMNode;
  end;


  { The following class is an implementation specific extension, it is just an
    extended implementation of TDOMNode, the generic DOM::Node interface
    implementation. (Its main purpose is to save memory in a big node tree) }

  TDOMNode_WithChildren = class(TDOMNode)
  protected
    FFirstChild, FLastChild: TDOMNode;
    function GetFirstChild: TDOMNode; override;
    function GetLastChild: TDOMNode; override;
    procedure CloneChildren(ACopy: TDOMNode; ACloneOwner: TDOMDocument);
  public
    destructor Destroy; override;
    function InsertBefore(NewChild, RefChild: TDOMNode): TDOMNode; override;
    function ReplaceChild(NewChild, OldChild: TDOMNode): TDOMNode; override;
    function RemoveChild(OldChild: TDOMNode): TDOMNode; override;
    function AppendChild(NewChild: TDOMNode): TDOMNode; override;
    function HasChildNodes: Boolean; override;
  end;


// -------------------------------------------------------
//   NodeList
// -------------------------------------------------------

  TDOMNodeList = class(TRefClass)
  protected
    node: TDOMNode;
    filter: DOMString;
    UseFilter: Boolean;
    constructor Create(ANode: TDOMNode; AFilter: DOMString);
    function GetCount: LongInt;
    function GetItem(index: LongWord): TDOMNode;
  public
    property Item[index: LongWord]: TDOMNode read GetItem;
    property Count: LongInt read GetCount;
  end;


// -------------------------------------------------------
//   NamedNodeMap
// -------------------------------------------------------

  TDOMNamedNodeMap = class(TList)
  protected
    OwnerDocument: TDOMDocument;
    function GetItem(index: LongWord): TDOMNode;
    procedure SetItem(index: LongWord; AItem: TDOMNode);
    function GetLength: LongWord;

    constructor Create(AOwner: TDOMDocument);
  public
    function GetNamedItem(const name: DOMString): TDOMNode;
    function SetNamedItem(arg: TDOMNode): TDOMNode;
    function RemoveNamedItem(const name: DOMString): TDOMNode;
    property Item[index: LongWord]: TDOMNode read GetItem write SetItem; default;
    property Length: LongWord read GetLength;
  end;


// -------------------------------------------------------
//   CharacterData
// -------------------------------------------------------

  TDOMCharacterData = class(TDOMNode)
  protected
    function  GetLength: LongWord;
  public
    property Data: DOMString read FNodeValue;
    property Length: LongWord read GetLength;
    function SubstringData(offset, count: LongWord): DOMString;
    procedure AppendData(const arg: DOMString);
    procedure InsertData(offset: LongWord; const arg: DOMString);
    procedure DeleteData(offset, count: LongWord);
    procedure ReplaceData(offset, count: LongWord; const arg: DOMString);
  end;


// -------------------------------------------------------
//   DOMImplementation
// -------------------------------------------------------

  TDOMImplementation = class
  public
    function HasFeature(const feature, version: DOMString): Boolean;

    // Introduced in DOM Level 2:

    function CreateDocumentType(const QualifiedName, PublicID,
      SystemID: DOMString): TDOMDocumentType;
    function CreateDocument(const NamespaceURI, QualifiedName: DOMString;
      doctype: TDOMDocumentType): TDOMDocument;
  end;


// -------------------------------------------------------
//   DocumentFragment
// -------------------------------------------------------

  TDOMDocumentFragment = class(TDOMNode_WithChildren)
  protected
    constructor Create(AOwner: TDOMDocument);
  end;


// -------------------------------------------------------
//   Document
// -------------------------------------------------------

  TDOMDocument = class(TDOMNode_WithChildren)
  protected
    FDocType: TDOMDocumentType;
    FImplementation: TDOMImplementation;
    function GetDocumentElement: TDOMElement;
  public
    property DocType: TDOMDocumentType read FDocType;
		property Impl: TDOMImplementation read FImplementation;
    property DocumentElement: TDOMElement read GetDocumentElement;

    function CreateElement(const tagName: DOMString): TDOMElement; virtual;
    function CreateDocumentFragment: TDOMDocumentFragment;
    function CreateTextNode(const data: DOMString): TDOMText;
    function CreateComment(const data: DOMString): TDOMComment;
    function CreateCDATASection(const data: DOMString): TDOMCDATASection;
      virtual;
    function CreateProcessingInstruction(const target, data: DOMString):
      TDOMProcessingInstruction; virtual;
    function CreateAttribute(const name: DOMString): TDOMAttr; virtual;
    function CreateEntityReference(const name: DOMString): TDOMEntityReference;
      virtual;
    // Free NodeList with TDOMNodeList.Release!
    function GetElementsByTagName(const tagname: DOMString): TDOMNodeList;

    // Extensions to DOM interface:
    constructor Create; virtual;
    function CreateEntity(const data: DOMString): TDOMEntity;
  end;

  TXMLDocument = class(TDOMDocument)
  public
		XMLVersion, Encoding: String;
    function CreateCDATASection(const data: DOMString): TDOMCDATASection; override;
		function CreateProcessingInstruction(const target, data: DOMString):
			TDOMProcessingInstruction; override;
		function CreateEntityReference(const name: DOMString): TDOMEntityReference; override;

		// Extensions to DOM interface:
	end;


// -------------------------------------------------------
//   Attr
// -------------------------------------------------------

  TDOMAttr = class(TDOMNode_WithChildren)
  protected
    FSpecified: Boolean;
    AttrOwner: TDOMNamedNodeMap;
    function  GetNodeValue: DOMString; override;
    procedure SetNodeValue(AValue: DOMString); override;

    constructor Create(AOwner: TDOMDocument);
  public
    function CloneNode(deep: Boolean; ACloneOwner: TDOMDocument): TDOMNode; override;
    property Name: DOMString read FNodeName;
    property Specified: Boolean read FSpecified;
    property Value: DOMString read FNodeValue write SetNodeValue;
  end;


// -------------------------------------------------------
//   Element
// -------------------------------------------------------

  TDOMElement = class(TDOMNode_WithChildren)
  protected
    FAttributes: TDOMNamedNodeMap;
    function GetAttributes: TDOMNamedNodeMap; override;

    constructor Create(AOwner: TDOMDocument); virtual;
  public
    destructor Destroy; override;
    function  CloneNode(deep: Boolean; ACloneOwner: TDOMDocument): TDOMNode; override;
    property  TagName: DOMString read FNodeName;
    function  GetAttribute(const name: DOMString): DOMString;
    procedure SetAttribute(const name, value: DOMString);
    procedure RemoveAttribute(const name: DOMString);
    function  GetAttributeNode(const name: DOMString): TDOMAttr;
    procedure SetAttributeNode(NewAttr: TDOMAttr);
    function  RemoveAttributeNode(OldAttr: TDOMAttr): TDOMAttr;
    // Free NodeList with TDOMNodeList.Release!
    function  GetElementsByTagName(const name: DOMString): TDOMNodeList;
    procedure Normalize;

    property AttribStrings[const Name: DOMString]: DOMString
      read GetAttribute write SetAttribute; default;
  end;


// -------------------------------------------------------
//   Text
// -------------------------------------------------------

  TDOMText = class(TDOMCharacterData)
  protected
    constructor Create(AOwner: TDOMDocument);
  public
    function  CloneNode(deep: Boolean; ACloneOwner: TDOMDocument): TDOMNode; override;
    function SplitText(offset: LongWord): TDOMText;
  end;


// -------------------------------------------------------
//   Comment
// -------------------------------------------------------

  TDOMComment = class(TDOMCharacterData)
  protected
    constructor Create(AOwner: TDOMDocument);
  public
    function CloneNode(deep: Boolean; ACloneOwner: TDOMDocument): TDOMNode; override;
  end;


// -------------------------------------------------------
//   CDATASection
// -------------------------------------------------------

  TDOMCDATASection = class(TDOMText)
  protected
    constructor Create(AOwner: TDOMDocument);
  public
    function CloneNode(deep: Boolean; ACloneOwner: TDOMDocument): TDOMNode; override;
  end;


// -------------------------------------------------------
//   DocumentType
// -------------------------------------------------------

  TDOMDocumentType = class(TDOMNode)
  protected
    FEntities, FNotations: TDOMNamedNodeMap;

    constructor Create(AOwner: TDOMDocument);
  public
    function CloneNode(deep: Boolean; ACloneOwner: TDOMDocument): TDOMNode; override;
    property Name: DOMString read FNodeName;
    property Entities: TDOMNamedNodeMap read FEntities;
    property Notations: TDOMNamedNodeMap read FEntities;
  end;


// -------------------------------------------------------
//   Notation
// -------------------------------------------------------

  TDOMNotation = class(TDOMNode)
  protected
    FPublicID, FSystemID: DOMString;

    constructor Create(AOwner: TDOMDocument);
  public
    function CloneNode(deep: Boolean; ACloneOwner: TDOMDocument): TDOMNode; override;
    property PublicID: DOMString read FPublicID;
    property SystemID: DOMString read FSystemID;
  end;


// -------------------------------------------------------
//   Entity
// -------------------------------------------------------

  TDOMEntity = class(TDOMNode_WithChildren)
  protected
    FPublicID, FSystemID, FNotationName: DOMString;

    constructor Create(AOwner: TDOMDocument);
  public
    property PublicID: DOMString read FPublicID;
    property SystemID: DOMString read FSystemID;
    property NotationName: DOMString read FNotationName;
  end;


// -------------------------------------------------------
//   EntityReference
// -------------------------------------------------------

  TDOMEntityReference = class(TDOMNode_WithChildren)
  protected
    constructor Create(AOwner: TDOMDocument);
  end;


// -------------------------------------------------------
//   ProcessingInstruction
// -------------------------------------------------------

  TDOMProcessingInstruction = class(TDOMNode)
  protected
    constructor Create(AOwner: TDOMDocument);
  public
    property Target: DOMString read FNodeName;
    property Data: DOMString read FNodeValue;
  end;




// =======================================================
// =======================================================

implementation


constructor TRefClass.Create;
begin
  inherited Create;
  RefCounter := 1;
end;

function TRefClass.AddRef: LongInt;
begin
  Inc(RefCounter);
  Result := RefCounter;
end;

function TRefClass.Release: LongInt;
begin
  Dec(RefCounter);
  Result := RefCounter;
  if RefCounter <= 0 then Free;
end;


// -------------------------------------------------------
//   DOM Exception
// -------------------------------------------------------

constructor EDOMError.Create(ACode: Integer; const ASituation: String);
begin
  Code := ACode;
  inherited Create(Self.ClassName + ' in ' + ASituation);
end;

constructor EDOMIndexSize.Create(const ASituation: String);    // 1
begin
  inherited Create(INDEX_SIZE_ERR, ASituation);
end;

constructor EDOMHierarchyRequest.Create(const ASituation: String);    // 3
begin
  inherited Create(HIERARCHY_REQUEST_ERR, ASituation);
end;

constructor EDOMWrongDocument.Create(const ASituation: String);    // 4
begin
  inherited Create(WRONG_DOCUMENT_ERR, ASituation);
end;

constructor EDOMNotFound.Create(const ASituation: String);    // 8
begin
  inherited Create(NOT_FOUND_ERR, ASituation);
end;

constructor EDOMNotSupported.Create(const ASituation: String);    // 9
begin
  inherited Create(NOT_SUPPORTED_ERR, ASituation);
end;

constructor EDOMInUseAttribute.Create(const ASituation: String);    // 10
begin
  inherited Create(INUSE_ATTRIBUTE_ERR, ASituation);
end;

constructor EDOMInvalidState.Create(const ASituation: String);    // 11
begin
  inherited Create(INVALID_STATE_ERR, ASituation);
end;

constructor EDOMSyntax.Create(const ASituation: String);    // 12
begin
  inherited Create(SYNTAX_ERR, ASituation);
end;

constructor EDOMInvalidModification.Create(const ASituation: String);    // 13
begin
  inherited Create(INVALID_MODIFICATION_ERR, ASituation);
end;

constructor EDOMNamespace.Create(const ASituation: String);    // 14
begin
  inherited Create(NAMESPACE_ERR, ASituation);
end;

constructor EDOMInvalidAccess.Create(const ASituation: String);    // 15
begin
  inherited Create(INVALID_ACCESS_ERR, ASituation);
end;


// -------------------------------------------------------
//   Node
// -------------------------------------------------------

constructor TDOMNode.Create(AOwner: TDOMDocument);
begin
  FOwnerDocument := AOwner;
  inherited Create;
end;

function TDOMNode.GetNodeValue: DOMString;
begin
  Result := FNodeValue;
end;

procedure TDOMNode.SetNodeValue(AValue: DOMString);
begin
  FNodeValue := AValue;
end;

function TDOMNode.GetChildNodes: TDOMNodeList;
begin
  Result := TDOMNodeList.Create(Self, '*');
end;

function TDOMNode.GetFirstChild: TDOMNode; begin Result := nil end;
function TDOMNode.GetLastChild: TDOMNode; begin Result := nil end;
function TDOMNode.GetAttributes: TDOMNamedNodeMap; begin Result := nil end;

function TDOMNode.InsertBefore(NewChild, RefChild: TDOMNode): TDOMNode;
begin
  raise EDOMHierarchyRequest.Create('Node.InsertBefore');
end;

function TDOMNode.ReplaceChild(NewChild, OldChild: TDOMNode): TDOMNode;
begin
  raise EDOMHierarchyRequest.Create('Node.ReplaceChild');
end;

function TDOMNode.RemoveChild(OldChild: TDOMNode): TDOMNode;
begin
  raise EDOMHierarchyRequest.Create('Node.RemoveChild');
end;

function TDOMNode.AppendChild(NewChild: TDOMNode): TDOMNode;
begin
  raise EDOMHierarchyRequest.Create('Node.AppendChild');
end;

function TDOMNode.HasChildNodes: Boolean;
begin
  Result := False;
end;

function TDOMNode.CloneNode(deep: Boolean): TDOMNode;
begin
//AC:  CloneNode(deep, FOwnerDocument);
  Result := CloneNode(deep, FOwnerDocument);    //AC:
end;

function TDOMNode.CloneNode(deep: Boolean; ACloneOwner: TDOMDocument): TDOMNode;
begin
  raise EDOMNotSupported.Create('CloneNode not implemented for ' + ClassName);
end;

function TDOMNode.FindNode(const ANodeName: DOMString): TDOMNode;
var
  child: TDOMNode;
begin
  child := FirstChild;
  while Assigned(child) do
  begin
    if child.NodeName = ANodeName then
    begin
      Result := child;
      exit;
    end;
    child := child.NextSibling;
  end;
  Result := nil;
end;


function TDOMNode_WithChildren.GetFirstChild: TDOMNode;
begin
  Result := FFirstChild;
end;

function TDOMNode_WithChildren.GetLastChild: TDOMNode;
begin
  Result := FLastChild;
end;

destructor TDOMNode_WithChildren.Destroy;
var
  child, next: TDOMNode;
begin
  child := FirstChild;
  while Assigned(child) do
  begin
    next := child.NextSibling;
    child.Free;
    child := next;
  end;
  inherited Destroy;
end;

function TDOMNode_WithChildren.InsertBefore(NewChild, RefChild: TDOMNode):
  TDOMNode;
begin
  Result := NewChild;

  if not Assigned(RefChild) then
  begin
    AppendChild(NewChild);
    exit;
  end;

  if NewChild.FOwnerDocument <> FOwnerDocument then
    raise EDOMWrongDocument.Create('NodeWC.InsertBefore');

  if RefChild.ParentNode <> Self then
    raise EDOMHierarchyRequest.Create('NodeWC.InsertBefore');

  if NewChild.NodeType = DOCUMENT_FRAGMENT_NODE then
    raise EDOMNotSupported.Create('NodeWC.InsertBefore for DocumentFragment');

  NewChild.FNextSibling := RefChild;
  if RefChild = FFirstChild then
    FFirstChild := NewChild
  else
    RefChild.FPreviousSibling.FNextSibling := NewChild;

  RefChild.FPreviousSibling := NewChild;
  NewChild.FParentNode := Self;
end;

function TDOMNode_WithChildren.ReplaceChild(NewChild, OldChild: TDOMNode):
  TDOMNode;
begin
  InsertBefore(NewChild, OldChild);
  if Assigned(OldChild) then
    RemoveChild(OldChild);
  Result := NewChild;
end;

function TDOMNode_WithChildren.RemoveChild(OldChild: TDOMNode):
  TDOMNode;
begin
  if OldChild.ParentNode <> Self then
    raise EDOMHierarchyRequest.Create('NodeWC.RemoveChild');

  if OldChild = FFirstChild then
    FFirstChild := FFirstChild.NextSibling
  else
    OldChild.FPreviousSibling.FNextSibling := OldChild.FNextSibling;

  if OldChild = FLastChild then
    FLastChild := FLastChild.FPreviousSibling
  else
    OldChild.FNextSibling.FPreviousSibling := OldChild.FPreviousSibling;

  OldChild.Free;
  Result := nil;  //AC:
end;

function TDOMNode_WithChildren.AppendChild(NewChild: TDOMNode): TDOMNode;
var
  Parent: TDOMNode;
begin
  if NewChild.FOwnerDocument <> FOwnerDocument then
    raise EDOMWrongDocument.Create('NodeWC.AppendChild');

  Parent := Self;
  while Assigned(Parent) do
  begin
    if Parent = NewChild then
      raise EDOMHierarchyRequest.Create('NodeWC.AppendChild (cycle in tree)');
    Parent := Parent.ParentNode;
  end;

  if NewChild.FParentNode = Self then
    RemoveChild(NewChild);

  if NewChild.NodeType = DOCUMENT_FRAGMENT_NODE then
    raise EDOMNotSupported.Create('NodeWC.AppendChild for DocumentFragments')
  else begin
    if Assigned(FFirstChild) then
    begin
      FLastChild.FNextSibling := NewChild;
      NewChild.FPreviousSibling := FLastChild;
    end else
      FFirstChild := NewChild;
    FLastChild := NewChild;
    NewChild.FParentNode := Self;
  end;
  Result := NewChild;
end;

function TDOMNode_WithChildren.HasChildNodes: Boolean;
begin
  Result := Assigned(FFirstChild);
end;

procedure TDOMNode_WithChildren.CloneChildren(ACopy: TDOMNode; ACloneOwner: TDOMDocument);
var
  node: TDOMNode;
begin
  node := FirstChild;
  while Assigned(node) do
  begin
    ACopy.AppendChild(node.CloneNode(True, ACloneOwner));
    node := node.NextSibling;
  end;
end;


// -------------------------------------------------------
//   NodeList
// -------------------------------------------------------

constructor TDOMNodeList.Create(ANode: TDOMNode; AFilter: DOMString);
begin
  inherited Create;
  node := ANode;
  filter := AFilter;
  UseFilter := filter <> '*';
end;

function TDOMNodeList.GetCount: LongInt;
var
  child: TDOMNode;
begin
  Result := 0;
  child := node.FirstChild;
  while Assigned(child) do
  begin
    if (not UseFilter) or (child.NodeName = filter) then
      Inc(Result);
    child := child.NextSibling;
  end;
end;

function TDOMNodeList.GetItem(index: LongWord): TDOMNode;
var
  child: TDOMNode;
begin
  Result := nil;
//Removed.  Longword is ranged from 0..423..., it can't be negative. RJM
{  if index < 0 then
    exit;}
  child := node.FirstChild;
  while Assigned(child) do
  begin
    if index = 0 then
    begin
      Result := child;
      break;
    end;
    if (not UseFilter) or (child.NodeName = filter) then
      Dec(index);
    child := child.NextSibling;
  end;
end;


// -------------------------------------------------------
//   NamedNodeMap
// -------------------------------------------------------

constructor TDOMNamedNodeMap.Create(AOwner: TDOMDocument);
begin
  inherited Create;
  OwnerDocument := AOwner;
end;

function TDOMNamedNodeMap.GetItem(index: LongWord): TDOMNode;
begin
  Result := TDOMNode(Items[index]);
end;

procedure TDOMNamedNodeMap.SetItem(index: LongWord; AItem: TDOMNode);
begin
  Items[index] := AItem;
end;

function TDOMNamedNodeMap.GetLength: LongWord;
begin
  Result := LongWord(Count);
end;

function TDOMNamedNodeMap.GetNamedItem(const name: DOMString): TDOMNode;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
		if Item[i].NodeName = name then
		begin
      Result := Item[i];
      Exit;
		end;
	Result := nil;
end;

function TDOMNamedNodeMap.SetNamedItem(arg: TDOMNode): TDOMNode;
var
  i: Integer;
begin
  if arg.FOwnerDocument <> OwnerDocument then
    raise EDOMWrongDocument.Create('NamedNodeMap.SetNamedItem');

  if arg.NodeType = ATTRIBUTE_NODE then
  begin
    if Assigned(TDOMAttr(arg).AttrOwner) then
      raise EDOMInUseAttribute.Create('NamedNodeMap.SetNamedItem');
    TDOMAttr(arg).AttrOwner := Self;
  end;

  for i := 0 to Count - 1 do
    if Item[i].NodeName = arg.NodeName then
    begin
      Result := Item[i];
      Item[i] := arg;
      exit;
    end;
  Add(arg);
  Result := nil;
end;

function TDOMNamedNodeMap.RemoveNamedItem(const name: DOMString): TDOMNode;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    if Item[i].NodeName = name then
    begin
      Result := Item[i];
      Result.FParentNode := nil;
      exit;
    end;
  raise EDOMNotFound.Create('NamedNodeMap.RemoveNamedItem');
end;


// -------------------------------------------------------
//   CharacterData
// -------------------------------------------------------

function TDOMCharacterData.GetLength: LongWord;
begin
  Result := system.Length(FNodeValue);
end;

function TDOMCharacterData.SubstringData(offset, count: LongWord): DOMString;
begin
//Modified.  Longword can't be a negative value... RJM
//  if (offset < 0) or (offset > Length) or (count < 0) then
  if (offset > Length) then
    raise EDOMIndexSize.Create('CharacterData.SubstringData');
  Result := Copy(FNodeValue, offset + 1, count);
end;

procedure TDOMCharacterData.AppendData(const arg: DOMString);
begin
  FNodeValue := FNodeValue + arg;
end;

procedure TDOMCharacterData.InsertData(offset: LongWord; const arg: DOMString);
begin
//Modified.  Longword can't be a negative value... RJM
//  if (offset < 0) or (offset > Length) then
  if (offset > Length) then
    raise EDOMIndexSize.Create('CharacterData.InsertData');

  FNodeValue := Copy(FNodeValue, 1, offset) + arg +
    Copy(FNodeValue, offset + 1, Length);
end;

procedure TDOMCharacterData.DeleteData(offset, count: LongWord);
begin
//Modified.  Longword can't be a negative value... RJM
//  if (offset < 0) or (offset > Length) or (count < 0) then
  if (offset > Length) then
    raise EDOMIndexSize.Create('CharacterData.DeleteData');

  FNodeValue := Copy(FNodeValue, 1, offset) +
    Copy(FNodeValue, offset + count + 1, Length);
end;

procedure TDOMCharacterData.ReplaceData(offset, count: LongWord; const arg: DOMString);
begin
  DeleteData(offset, count);
  InsertData(offset, arg);
end;


// -------------------------------------------------------
//   DocumentFragmet
// -------------------------------------------------------

constructor TDOMDocumentFragment.Create(AOwner: TDOMDocument);
begin
  FNodeType := DOCUMENT_FRAGMENT_NODE;
  FNodeName := '#document-fragment';
  inherited Create(AOwner);
end;


// -------------------------------------------------------
//   DOMImplementation
// -------------------------------------------------------

function TDOMImplementation.HasFeature(const feature, version: DOMString):
  Boolean;
begin
  Result := False;
end;

function TDOMImplementation.CreateDocumentType(const QualifiedName, PublicID,
  SystemID: DOMString): TDOMDocumentType;
begin
  // !!!: Implement this method (easy to do)
  raise EDOMNotSupported.Create('DOMImplementation.CreateDocumentType');
end;

function TDOMImplementation.CreateDocument(const NamespaceURI,
  QualifiedName: DOMString; doctype: TDOMDocumentType): TDOMDocument;
begin
  // !!!: Implement this method (easy to do)
  raise EDOMNotSupported.Create('DOMImplementation.CreateDocument');
end;


// -------------------------------------------------------
//   Document
// -------------------------------------------------------

constructor TDOMDocument.Create;
begin
  FNodeType := DOCUMENT_NODE;
  FNodeName := '#document';
  inherited Create(nil);
  FOwnerDocument := Self;
end;

function TDOMDocument.GetDocumentElement: TDOMElement;
var
  node: TDOMNode;
begin
  node := FFirstChild;
  while Assigned(node) do
  begin
    if node.FNodeType = ELEMENT_NODE then
    begin
      Result := TDOMElement(node);
      exit;
    end;
    node := node.NextSibling;
  end;
  Result := nil;
end;

function TDOMDocument.CreateElement(const tagName: DOMString): TDOMElement;
begin
  Result := TDOMElement.Create(Self);
  Result.FNodeName := tagName;
end;

function TDOMDocument.CreateDocumentFragment: TDOMDocumentFragment;
begin
  Result := TDOMDocumentFragment.Create(Self);
end;

function TDOMDocument.CreateTextNode(const data: DOMString): TDOMText;
begin
  Result := TDOMText.Create(Self);
  Result.FNodeValue := data;
end;

function TDOMDocument.CreateComment(const data: DOMString): TDOMComment;
begin
  Result := TDOMComment.Create(Self);
  Result.FNodeValue := data;
end;

function TDOMDocument.CreateCDATASection(const data: DOMString):
  TDOMCDATASection;
begin
  raise EDOMNotSupported.Create('DOMDocument.CreateCDATASection');
end;

function TDOMDocument.CreateProcessingInstruction(const target,
  data: DOMString): TDOMProcessingInstruction;
begin
  raise EDOMNotSupported.Create('DOMDocument.CreateProcessingInstruction');
end;

function TDOMDocument.CreateAttribute(const name: DOMString): TDOMAttr;
begin
  Result := TDOMAttr.Create(Self);
  Result.FNodeName := name;
end;

function TDOMDocument.CreateEntityReference(const name: DOMString):
  TDOMEntityReference;
begin
  raise EDOMNotSupported.Create('DOMDocument.CreateEntityReference');
end;

function TDOMDocument.CreateEntity(const data: DOMString): TDOMEntity;
begin
  Result := TDOMEntity.Create(Self);
  Result.FNodeName := data;
end;

function TDOMDocument.GetElementsByTagName(const tagname: DOMString): TDOMNodeList;
begin
  Result := TDOMNodeList.Create(Self, tagname);
end;


function TXMLDocument.CreateCDATASection(const data: DOMString):
  TDOMCDATASection;
begin
  Result := TDOMCDATASection.Create(Self);
  Result.FNodeValue := data;
end;

function TXMLDocument.CreateProcessingInstruction(const target,
  data: DOMString): TDOMProcessingInstruction;
begin
  Result := TDOMProcessingInstruction.Create(Self);
  Result.FNodeName := target;
  Result.FNodeValue := data;
end;

function TXMLDocument.CreateEntityReference(const name: DOMString):
  TDOMEntityReference;
begin
  Result := TDOMEntityReference.Create(Self);
  Result.FNodeName := name;
end;


// -------------------------------------------------------
//   Attr
// -------------------------------------------------------

constructor TDOMAttr.Create(AOwner: TDOMDocument);
begin
  FNodeType := ATTRIBUTE_NODE;
  inherited Create(AOwner);
end;

function TDOMAttr.CloneNode(deep: Boolean; ACloneOwner: TDOMDocument): TDOMNode;
begin
  Result := TDOMAttr.Create(ACloneOwner);
  Result.FNodeName := FNodeName;
  TDOMAttr(Result).FSpecified := FSpecified;
  if deep then
    CloneChildren(Result, ACloneOwner);
end;

function TDOMAttr.GetNodeValue: DOMString;
var
  child: TDOMNode;
begin
  SetLength(Result, 0);
  if Assigned(FFirstChild) then
  begin
    child := FFirstChild;
    while Assigned(child) do
    begin
      if child.NodeType = ENTITY_REFERENCE_NODE then
        Result := Result + '&' + child.NodeName + ';'
      else
        Result := Result + child.NodeValue;
      child := child.NextSibling;
    end;
  end;
end;

procedure TDOMAttr.SetNodeValue(AValue: DOMString);
var
  tn: TDOMText;
begin
  FSpecified := True;
  tn := TDOMText.Create(FOwnerDocument);
  tn.FNodeValue := AValue;
  if Assigned(FFirstChild) then
    ReplaceChild(tn, FFirstChild)
  else
    AppendChild(tn);
end;


// -------------------------------------------------------
//   Element
// -------------------------------------------------------

constructor TDOMElement.Create(AOwner: TDOMDocument);
begin
  FNodeType := ELEMENT_NODE;
  inherited Create(AOwner);
  FAttributes := TDOMNamedNodeMap.Create(AOwner);
end;

destructor TDOMElement.Destroy;
var
  i: Integer;
begin
  {As the attributes are _not_ childs of the element node, we have to free
   them manually here:}
  for i := 0 to FAttributes.Count - 1 do
    FAttributes[i].Free;
  FAttributes.Free;
  inherited Destroy;
end;

function TDOMElement.CloneNode(deep: Boolean; ACloneOwner: TDOMDocument): TDOMNode;
var
  i: Integer;
begin
  Result := TDOMElement.Create(ACloneOwner);
  Result.FNodeName := FNodeName;
  for i := 0 to FAttributes.Count - 1 do
    TDOMElement(Result).FAttributes.Add(FAttributes[i].CloneNode(True, ACloneOwner));
  if deep then
    CloneChildren(Result, ACloneOwner);
end;

function TDOMElement.GetAttributes: TDOMNamedNodeMap;
begin
  Result := FAttributes;
end;

function TDOMElement.GetAttribute(const name: DOMString): DOMString;
var
  i: Integer;
begin
  for i := 0 to FAttributes.Count - 1 do
    if FAttributes[i].NodeName = name then
    begin
      Result := FAttributes[i].NodeValue;
      exit;
    end;
  SetLength(Result, 0);
end;

procedure TDOMElement.SetAttribute(const name, value: DOMString);
var
  i: Integer;
  attr: TDOMAttr;
begin
  for i := 0 to FAttributes.Count - 1 do
    if FAttributes[i].NodeName = name then
    begin
      FAttributes[i].NodeValue := value;
      exit;
    end;
  attr := TDOMAttr.Create(FOwnerDocument);
  attr.FNodeName := name;
  attr.NodeValue := value;
  FAttributes.Add(attr);
end;

procedure TDOMElement.RemoveAttribute(const name: DOMString);
var
  i: Integer;
begin
  for i := 0 to FAttributes.Count - 1 do
    if FAttributes[i].NodeName = name then
    begin
      FAttributes[i].Free;
      FAttributes.Delete(i);
      exit;
    end;
end;

function TDOMElement.GetAttributeNode(const name: DOMString): TDOMAttr;
var
  i: Integer;
begin
  for i := 0 to FAttributes.Count - 1 do
    if FAttributes[i].NodeName = name then
    begin
      Result := TDOMAttr(FAttributes[i]);
      exit;
    end;
  Result := nil;
end;

procedure TDOMElement.SetAttributeNode(NewAttr: TDOMAttr);
var
  i: Integer;
begin
  for i := 0 to FAttributes.Count - 1 do
    if FAttributes[i].NodeName = NewAttr.NodeName then
    begin
      FAttributes[i].Free;
      FAttributes[i] := NewAttr;
      exit;
    end;
end;

function TDOMElement.RemoveAttributeNode(OldAttr: TDOMAttr): TDOMAttr;
var
  i: Integer;
  node: TDOMNode;
begin
  result := nil; //added to remove a compiler warning... RJM
  for i := 0 to FAttributes.Count - 1 do
  begin
    node := FAttributes[i];
    if node = OldAttr then
    begin
      FAttributes.Delete(i);
      Result := TDOMAttr(node);
      exit;
    end;
  end;
end;

function TDOMElement.GetElementsByTagName(const name: DOMString): TDOMNodeList;
begin
  Result := TDOMNodeList.Create(Self, name);
end;

procedure TDOMElement.Normalize;
begin
  // !!!: Not implemented
end;


// -------------------------------------------------------
//   Text
// -------------------------------------------------------

constructor TDOMText.Create(AOwner: TDOMDocument);
begin
  FNodeType := TEXT_NODE;
  FNodeName := '#text';
  inherited Create(AOwner);
end;

function TDOMText.CloneNode(deep: Boolean; ACloneOwner: TDOMDocument): TDOMNode;
begin
  Result := TDOMText.Create(ACloneOwner);
  Result.FNodeValue := FNodeValue;
end;

function TDOMText.SplitText(offset: LongWord): TDOMText;
var
  nt: TDOMText;
begin
  result := nil; //added to remove compiler warning. RJM 

  if offset > Length then
    raise EDOMIndexSize.Create('Text.SplitText');

  nt := TDOMText.Create(FOwnerDocument);
  nt.FNodeValue := Copy(FNodeValue, offset + 1, Length);
  FNodeValue := Copy(FNodeValue, 1, offset);
  FParentNode.InsertBefore(nt, FNextSibling);
end;


// -------------------------------------------------------
//   Comment
// -------------------------------------------------------

constructor TDOMComment.Create(AOwner: TDOMDocument);
begin
  FNodeType := COMMENT_NODE;
  FNodeName := '#comment';
  inherited Create(AOwner);
end;

function TDOMComment.CloneNode(deep: Boolean; ACloneOwner: TDOMDocument): TDOMNode;
begin
  Result := TDOMComment.Create(ACloneOwner);
  Result.FNodeValue := FNodeValue;
end;


// -------------------------------------------------------
//   CDATASection
// -------------------------------------------------------

constructor TDOMCDATASection.Create(AOwner: TDOMDocument);
begin
  inherited Create(AOwner);
  FNodeType := CDATA_SECTION_NODE;
  FNodeName := '#cdata-section';
end;

function TDOMCDATASection.CloneNode(deep: Boolean; ACloneOwner: TDOMDocument): TDOMNode;
begin
  Result := TDOMCDATASection.Create(ACloneOwner);
  Result.FNodeValue := FNodeValue;
end;


// -------------------------------------------------------
//   DocumentType
// -------------------------------------------------------

constructor TDOMDocumentType.Create(AOwner: TDOMDocument);
begin
  FNodeType := DOCUMENT_TYPE_NODE;
  inherited Create(AOwner);
end;

function TDOMDocumentType.CloneNode(deep: Boolean; ACloneOwner: TDOMDocument): TDOMNode;
begin
  Result := TDOMDocumentType.Create(ACloneOwner);
  Result.FNodeName := FNodeName;
end;


// -------------------------------------------------------
//   Notation
// -------------------------------------------------------

constructor TDOMNotation.Create(AOwner: TDOMDocument);
begin
  FNodeType := NOTATION_NODE;
  inherited Create(AOwner);
end;

function TDOMNotation.CloneNode(deep: Boolean; ACloneOwner: TDOMDocument): TDOMNode;
begin
  Result := TDOMNotation.Create(ACloneOwner);
  Result.FNodeName := FNodeName;
end;


// -------------------------------------------------------
//   Entity
// -------------------------------------------------------

constructor TDOMEntity.Create(AOwner: TDOMDocument);
begin
  FNodeType := ENTITY_NODE;
  inherited Create(AOwner);
end;


// -------------------------------------------------------
//   EntityReference
// -------------------------------------------------------

constructor TDOMEntityReference.Create(AOwner: TDOMDocument);
begin
  FNodeType := ENTITY_REFERENCE_NODE;
  inherited Create(AOwner);
end;


// -------------------------------------------------------
//   ProcessingInstruction
// -------------------------------------------------------

constructor TDOMProcessingInstruction.Create(AOwner: TDOMDocument);
begin
  FNodeType := PROCESSING_INSTRUCTION_NODE;
  inherited Create(AOwner);
end;


end.
