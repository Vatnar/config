// Decompiled with JetBrains decompiler
// Type: Microsoft.AspNetCore.Mvc.Razor.RazorPageBase
// Assembly: Microsoft.AspNetCore.Mvc.Razor, Version=9.0.0.0, Culture=neutral, PublicKeyToken=adb9793829ddae60
// MVID: 2EAEB081-29EE-4AE3-BD7E-06DC118853F2
// Assembly location: /usr/share/dotnet/shared/Microsoft.AspNetCore.App/9.0.7/Microsoft.AspNetCore.Mvc.Razor.dll

using Microsoft.AspNetCore.Antiforgery;
using Microsoft.AspNetCore.Html;
using Microsoft.AspNetCore.Mvc.Razor.Internal;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.AspNetCore.Mvc.Routing;
using Microsoft.AspNetCore.Mvc.ViewFeatures;
using Microsoft.AspNetCore.Mvc.ViewFeatures.Buffers;
using Microsoft.AspNetCore.Razor.Runtime.TagHelpers;
using Microsoft.AspNetCore.Razor.TagHelpers;
using Microsoft.Extensions.DependencyInjection;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Diagnostics;
using System.IO;
using System.Security.Claims;
using System.Text.Encodings.Web;
using System.Threading.Tasks;

#nullable enable
namespace Microsoft.AspNetCore.Mvc.Razor;

public abstract class RazorPageBase : IRazorPage
{
  #nullable disable
  private readonly Stack<TextWriter> _textWriterStack = new Stack<TextWriter>();
  private readonly IDictionary<string, RenderAsyncDelegate> _sectionWriters = (IDictionary<string, RenderAsyncDelegate>) new Dictionary<string, RenderAsyncDelegate>((IEqualityComparer<string>) StringComparer.OrdinalIgnoreCase);
  private StringWriter _valueBuffer;
  private ITagHelperFactory _tagHelperFactory;
  private IViewBufferScope _bufferScope;
  private TextWriter _pageWriter;
  private RazorPageBase.AttributeInfo _attributeInfo;
  private RazorPageBase.TagHelperAttributeInfo _tagHelperAttributeInfo;
  private IUrlHelper _urlHelper;
  private bool _isLayoutBeingRendered;
  private IHtmlContent _bodyContent;
  private IDictionary<string, RenderAsyncDelegate> _previousSectionWriters;
  private DiagnosticSource _diagnosticSource;
  private HtmlEncoder _htmlEncoder;

  #nullable enable
  public virtual ViewContext ViewContext { get; set; }

  public string? Layout { get; set; }

  [DebuggerBrowsable(DebuggerBrowsableState.Never)]
  public virtual TextWriter Output
  {
    get
    {
      return (this.ViewContext ?? throw new InvalidOperationException(Resources.FormatViewContextMustBeSet((object) "ViewContext", (object) nameof (Output)))).Writer;
    }
  }

  public string Path { get; set; }

  [DebuggerBrowsable(DebuggerBrowsableState.Never)]
  public IDictionary<string, RenderAsyncDelegate> SectionWriters => this._sectionWriters;

  public object ViewBag => this.ViewContext?.ViewBag;

  [DebuggerBrowsable(DebuggerBrowsableState.Never)]
  public bool IsLayoutBeingRendered
  {
    get => this._isLayoutBeingRendered;
    set => this._isLayoutBeingRendered = value;
  }

  [DebuggerBrowsable(DebuggerBrowsableState.Never)]
  public IHtmlContent? BodyContent
  {
    get => this._bodyContent;
    set => this._bodyContent = value;
  }

  [DebuggerBrowsable(DebuggerBrowsableState.Never)]
  public IDictionary<string, RenderAsyncDelegate> PreviousSectionWriters
  {
    get => this._previousSectionWriters;
    set => this._previousSectionWriters = value;
  }

  [RazorInject]
  [DebuggerBrowsable(DebuggerBrowsableState.Never)]
  public DiagnosticSource DiagnosticSource
  {
    get => this._diagnosticSource;
    set => this._diagnosticSource = value;
  }

  [RazorInject]
  [DebuggerBrowsable(DebuggerBrowsableState.Never)]
  public HtmlEncoder HtmlEncoder
  {
    get => this._htmlEncoder;
    set => this._htmlEncoder = value;
  }

  public virtual ClaimsPrincipal User => this.ViewContext.HttpContext.User;

  public ITempDataDictionary TempData => this.ViewContext?.TempData;

  private Stack<RazorPageBase.TagHelperScopeInfo> TagHelperScopes { get; } = new Stack<RazorPageBase.TagHelperScopeInfo>();

  private ITagHelperFactory TagHelperFactory
  {
    get
    {
      if (this._tagHelperFactory == null)
        this._tagHelperFactory = this.ViewContext.HttpContext.RequestServices.GetRequiredService<ITagHelperFactory>();
      return this._tagHelperFactory;
    }
  }

  private IViewBufferScope BufferScope
  {
    get
    {
      if (this._bufferScope == null)
        this._bufferScope = this.ViewContext.HttpContext.RequestServices.GetRequiredService<IViewBufferScope>();
      return this._bufferScope;
    }
  }

  public abstract Task ExecuteAsync();

  [EditorBrowsable(EditorBrowsableState.Never)]
  public string InvalidTagHelperIndexerAssignment(
    string attributeName,
    string tagHelperTypeName,
    string propertyName)
  {
    return Resources.FormatRazorPage_InvalidTagHelperIndexerAssignment((object) attributeName, (object) tagHelperTypeName, (object) propertyName);
  }

  public TTagHelper CreateTagHelper<TTagHelper>() where TTagHelper : ITagHelper
  {
    return this.TagHelperFactory.CreateTagHelper<TTagHelper>(this.ViewContext);
  }

  public void StartTagHelperWritingScope(HtmlEncoder encoder)
  {
    ViewContext viewContext = this.ViewContext;
    ViewBuffer buffer = new ViewBuffer(this.BufferScope, this.Path, 32 /*0x20*/);
    this.TagHelperScopes.Push(new RazorPageBase.TagHelperScopeInfo(buffer, this.HtmlEncoder, viewContext.Writer));
    if (encoder != null)
      this.HtmlEncoder = encoder;
    viewContext.Writer = (TextWriter) new ViewBufferTextWriter(buffer, viewContext.Writer.Encoding);
  }

  public TagHelperContent EndTagHelperWritingScope()
  {
    RazorPageBase.TagHelperScopeInfo tagHelperScopeInfo = this.TagHelperScopes.Count != 0 ? this.TagHelperScopes.Pop() : throw new InvalidOperationException(Resources.RazorPage_ThereIsNoActiveWritingScopeToEnd);
    DefaultTagHelperContent tagHelperContent = new DefaultTagHelperContent();
    tagHelperContent.AppendHtml((IHtmlContent) tagHelperScopeInfo.Buffer);
    this.HtmlEncoder = tagHelperScopeInfo.HtmlEncoder;
    this.ViewContext.Writer = tagHelperScopeInfo.Writer;
    return (TagHelperContent) tagHelperContent;
  }

  public void BeginWriteTagHelperAttribute()
  {
    if (this._pageWriter != null)
      throw new InvalidOperationException(Resources.RazorPage_NestingAttributeWritingScopesNotSupported);
    ViewContext viewContext = this.ViewContext;
    this._pageWriter = viewContext.Writer;
    if (this._valueBuffer == null)
      this._valueBuffer = new StringWriter();
    viewContext.Writer = (TextWriter) this._valueBuffer;
  }

  public string EndWriteTagHelperAttribute()
  {
    if (this._pageWriter == null)
      throw new InvalidOperationException(Resources.RazorPage_ThereIsNoActiveWritingScopeToEnd);
    string str = this._valueBuffer.ToString();
    this._valueBuffer.GetStringBuilder().Clear();
    this.ViewContext.Writer = this._pageWriter;
    this._pageWriter = (TextWriter) null;
    return str;
  }

  protected internal virtual void PushWriter(TextWriter writer)
  {
    ArgumentNullException.ThrowIfNull((object) writer, nameof (writer));
    ViewContext viewContext = this.ViewContext;
    this._textWriterStack.Push(viewContext.Writer);
    viewContext.Writer = writer;
  }

  protected internal virtual TextWriter PopWriter()
  {
    ViewContext viewContext = this.ViewContext;
    TextWriter textWriter1 = this._textWriterStack.Pop();
    TextWriter textWriter2 = textWriter1;
    viewContext.Writer = textWriter2;
    return textWriter1;
  }

  public virtual string Href(string contentPath)
  {
    ArgumentNullException.ThrowIfNull((object) contentPath, nameof (contentPath));
    if (this._urlHelper == null)
    {
      ViewContext viewContext = this.ViewContext;
      this._urlHelper = viewContext.HttpContext.RequestServices.GetRequiredService<IUrlHelperFactory>().GetUrlHelper((ActionContext) viewContext);
    }
    return this._urlHelper.Content(contentPath);
  }

  [EditorBrowsable(EditorBrowsableState.Never)]
  protected void DefineSection(string name, Func<object?, Task> section)
  {
    this.DefineSection(name, (RenderAsyncDelegate) (() => section((object) null)));
  }

  public virtual void DefineSection(string name, RenderAsyncDelegate section)
  {
    ArgumentNullException.ThrowIfNull((object) name, nameof (name));
    ArgumentNullException.ThrowIfNull((object) section, nameof (section));
    if (this.SectionWriters.ContainsKey(name))
      throw new InvalidOperationException(Resources.FormatSectionAlreadyDefined((object) name));
    this.SectionWriters[name] = section;
  }

  public virtual void Write(object? value)
  {
    if (value == null || value == HtmlString.Empty)
      return;
    TextWriter output = this.Output;
    HtmlEncoder htmlEncoder = this.HtmlEncoder;
    if (value is IHtmlContent content)
    {
      if (output is ViewBufferTextWriter bufferTextWriter)
      {
        if (value is IHtmlContentContainer contentContainer)
          contentContainer.MoveTo((IHtmlContentBuilder) bufferTextWriter.Buffer);
        else
          bufferTextWriter.Buffer.AppendHtml(content);
      }
      else
        content.WriteTo(output, htmlEncoder);
    }
    else
      this.Write(value.ToString());
  }

  public virtual void Write(string? value)
  {
    TextWriter output = this.Output;
    HtmlEncoder htmlEncoder = this.HtmlEncoder;
    if (string.IsNullOrEmpty(value))
      return;
    string str = htmlEncoder.Encode(value);
    output.Write(str);
  }

  public virtual void WriteLiteral(object? value)
  {
    if (value == null)
      return;
    this.WriteLiteral(value.ToString());
  }

  public virtual void WriteLiteral(string? value)
  {
    if (string.IsNullOrEmpty(value))
      return;
    this.Output.Write(value);
  }

  public virtual void BeginWriteAttribute(
    string name,
    string prefix,
    int prefixOffset,
    string suffix,
    int suffixOffset,
    int attributeValuesCount)
  {
    ArgumentNullException.ThrowIfNull((object) prefix, nameof (prefix));
    ArgumentNullException.ThrowIfNull((object) suffix, nameof (suffix));
    this._attributeInfo = new RazorPageBase.AttributeInfo(name, prefix, prefixOffset, suffix, suffixOffset, attributeValuesCount);
    if (attributeValuesCount == 1)
      return;
    this.WritePositionTaggedLiteral(prefix, prefixOffset);
  }

  public void WriteAttributeValue(
    string prefix,
    int prefixOffset,
    object? value,
    int valueOffset,
    int valueLength,
    bool isLiteral)
  {
    if (this._attributeInfo.AttributeValuesCount == 1)
    {
      if (RazorPageBase.IsBoolFalseOrNullValue(prefix, value))
      {
        this._attributeInfo.Suppressed = true;
        return;
      }
      this.WritePositionTaggedLiteral(this._attributeInfo.Prefix, this._attributeInfo.PrefixOffset);
      if (RazorPageBase.IsBoolTrueWithEmptyPrefixValue(prefix, value))
        value = (object) this._attributeInfo.Name;
    }
    if (value == null)
      return;
    if (!string.IsNullOrEmpty(prefix))
      this.WritePositionTaggedLiteral(prefix, prefixOffset);
    this.BeginContext(valueOffset, valueLength, isLiteral);
    this.WriteUnprefixedAttributeValue(value, isLiteral);
    this.EndContext();
  }

  public virtual void EndWriteAttribute()
  {
    if (this._attributeInfo.Suppressed)
      return;
    this.WritePositionTaggedLiteral(this._attributeInfo.Suffix, this._attributeInfo.SuffixOffset);
  }

  public void BeginAddHtmlAttributeValues(
    TagHelperExecutionContext executionContext,
    string attributeName,
    int attributeValuesCount,
    HtmlAttributeValueStyle attributeValueStyle)
  {
    this._tagHelperAttributeInfo = new RazorPageBase.TagHelperAttributeInfo(executionContext, attributeName, attributeValuesCount, attributeValueStyle);
  }

  public void AddHtmlAttributeValue(
    string? prefix,
    int prefixOffset,
    object? value,
    int valueOffset,
    int valueLength,
    bool isLiteral)
  {
    if (this._tagHelperAttributeInfo.AttributeValuesCount == 1)
    {
      if (RazorPageBase.IsBoolFalseOrNullValue(prefix, value))
      {
        this._tagHelperAttributeInfo.ExecutionContext.AddTagHelperAttribute(this._tagHelperAttributeInfo.Name, (object) (value?.ToString() ?? string.Empty), this._tagHelperAttributeInfo.AttributeValueStyle);
        this._tagHelperAttributeInfo.Suppressed = true;
        return;
      }
      if (RazorPageBase.IsBoolTrueWithEmptyPrefixValue(prefix, value))
      {
        this._tagHelperAttributeInfo.ExecutionContext.AddHtmlAttribute(this._tagHelperAttributeInfo.Name, (object) this._tagHelperAttributeInfo.Name, this._tagHelperAttributeInfo.AttributeValueStyle);
        this._tagHelperAttributeInfo.Suppressed = true;
        return;
      }
    }
    if (value == null)
      return;
    if (this._valueBuffer == null)
      this._valueBuffer = new StringWriter();
    this.PushWriter((TextWriter) this._valueBuffer);
    if (!string.IsNullOrEmpty(prefix))
      this.WriteLiteral(prefix);
    this.WriteUnprefixedAttributeValue(value, isLiteral);
    this.PopWriter();
  }

  public void EndAddHtmlAttributeValues(TagHelperExecutionContext executionContext)
  {
    if (this._tagHelperAttributeInfo.Suppressed)
      return;
    HtmlString htmlString = this._valueBuffer == null ? HtmlString.Empty : new HtmlString(this._valueBuffer.ToString());
    this._valueBuffer?.GetStringBuilder().Clear();
    executionContext.AddHtmlAttribute(this._tagHelperAttributeInfo.Name, (object) htmlString, this._tagHelperAttributeInfo.AttributeValueStyle);
  }

  public virtual async Task<HtmlString> FlushAsync()
  {
    if (this.TagHelperScopes.Count > 0)
      throw new InvalidOperationException(Resources.FormatRazorPage_CannotFlushWhileInAWritingScope((object) nameof (FlushAsync), (object) this.Path));
    if (!this.IsLayoutBeingRendered && !string.IsNullOrEmpty(this.Layout))
      throw new InvalidOperationException(Resources.FormatLayoutCannotBeRendered((object) this.Path, (object) nameof (FlushAsync)));
    await this.Output.FlushAsync();
    await this.ViewContext.HttpContext.Response.Body.FlushAsync();
    return HtmlString.Empty;
  }

  public virtual HtmlString SetAntiforgeryCookieAndHeader()
  {
    ViewContext viewContext = this.ViewContext;
    if (viewContext != null)
      viewContext.HttpContext.RequestServices.GetRequiredService<IAntiforgery>().SetCookieTokenAndHeader(viewContext.HttpContext);
    return HtmlString.Empty;
  }

  #nullable disable
  private void WriteUnprefixedAttributeValue(object value, bool isLiteral)
  {
    if (value is string str)
    {
      if (isLiteral)
        this.WriteLiteral(str);
      else
        this.Write(str);
    }
    else if (isLiteral)
      this.WriteLiteral(value);
    else
      this.Write(value);
  }

  private void WritePositionTaggedLiteral(string value, int position)
  {
    this.BeginContext(position, value.Length, true);
    this.WriteLiteral(value);
    this.EndContext();
  }

  public abstract void BeginContext(int position, int length, bool isLiteral);

  public abstract void EndContext();

  private static bool IsBoolFalseOrNullValue(string prefix, object value)
  {
    if (!string.IsNullOrEmpty(prefix))
      return false;
    if (value == null)
      return true;
    return value is bool flag && !flag;
  }

  private static bool IsBoolTrueWithEmptyPrefixValue(string prefix, object value)
  {
    return string.IsNullOrEmpty(prefix) && ((!(value is bool flag) ? 0 : 1) & (flag ? 1 : 0)) != 0;
  }

  public abstract void EnsureRenderedBodyOrSections();

  private struct AttributeInfo(
    string name,
    string prefix,
    int prefixOffset,
    string suffix,
    int suffixOffset,
    int attributeValuesCount)
  {
    public int AttributeValuesCount { get; } = attributeValuesCount;

    public string Name { get; } = name;

    public string Prefix { get; } = prefix;

    public int PrefixOffset { get; } = prefixOffset;

    public string Suffix { get; } = suffix;

    public int SuffixOffset { get; } = suffixOffset;

    public bool Suppressed { get; set; } = false;
  }

  private struct TagHelperAttributeInfo(
    TagHelperExecutionContext tagHelperExecutionContext,
    string name,
    int attributeValuesCount,
    HtmlAttributeValueStyle attributeValueStyle)
  {
    public string Name { get; } = name;

    public TagHelperExecutionContext ExecutionContext { get; } = tagHelperExecutionContext;

    public int AttributeValuesCount { get; } = attributeValuesCount;

    public HtmlAttributeValueStyle AttributeValueStyle { get; } = attributeValueStyle;

    public bool Suppressed { get; set; } = false;
  }

  private readonly struct TagHelperScopeInfo(
    ViewBuffer buffer,
    HtmlEncoder encoder,
    TextWriter writer)
  {
    public ViewBuffer Buffer { get; } = buffer;

    public HtmlEncoder HtmlEncoder { get; } = encoder;

    public TextWriter Writer { get; } = writer;
  }
}
