// Decompiled with JetBrains decompiler
// Type: Microsoft.AspNetCore.Mvc.Rendering.ViewContext
// Assembly: Microsoft.AspNetCore.Mvc.ViewFeatures, Version=9.0.0.0, Culture=neutral, PublicKeyToken=adb9793829ddae60
// MVID: C1A21F05-1BA4-4187-A0FA-7766E95B0DAB
// Assembly location: /usr/share/dotnet/shared/Microsoft.AspNetCore.App/9.0.7/Microsoft.AspNetCore.Mvc.ViewFeatures.dll

using Microsoft.AspNetCore.Mvc.ModelBinding;
using Microsoft.AspNetCore.Mvc.ViewEngines;
using Microsoft.AspNetCore.Mvc.ViewFeatures;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;

#nullable enable
namespace Microsoft.AspNetCore.Mvc.Rendering;

[DebuggerDisplay("{DebuggerToString(),nq}")]
public class ViewContext : ActionContext
{
  #nullable disable
  private FormContext _formContext;
  private DynamicViewData _viewBag;
  private Dictionary<object, object> _items;

  public ViewContext()
  {
    this.ViewData = new ViewDataDictionary((IModelMetadataProvider) new EmptyModelMetadataProvider(), this.ModelState);
  }

  #nullable enable
  public ViewContext(
    ActionContext actionContext,
    IView view,
    ViewDataDictionary viewData,
    ITempDataDictionary tempData,
    TextWriter writer,
    HtmlHelperOptions htmlHelperOptions)
    : base(actionContext)
  {
    ArgumentNullException.ThrowIfNull((object) actionContext, nameof (actionContext));
    ArgumentNullException.ThrowIfNull((object) view, nameof (view));
    ArgumentNullException.ThrowIfNull((object) viewData, nameof (viewData));
    ArgumentNullException.ThrowIfNull((object) tempData, nameof (tempData));
    ArgumentNullException.ThrowIfNull((object) writer, nameof (writer));
    ArgumentNullException.ThrowIfNull((object) htmlHelperOptions, nameof (htmlHelperOptions));
    this.View = view;
    this.ViewData = viewData;
    this.TempData = tempData;
    this.Writer = writer;
    this.FormContext = new FormContext();
    this.ClientValidationEnabled = htmlHelperOptions.ClientValidationEnabled;
    this.Html5DateRenderingMode = htmlHelperOptions.Html5DateRenderingMode;
    this.ValidationSummaryMessageElement = htmlHelperOptions.ValidationSummaryMessageElement;
    this.ValidationMessageElement = htmlHelperOptions.ValidationMessageElement;
    this.CheckBoxHiddenInputRenderMode = htmlHelperOptions.CheckBoxHiddenInputRenderMode;
  }

  public ViewContext(
    ViewContext viewContext,
    IView view,
    ViewDataDictionary viewData,
    TextWriter writer)
    : base((ActionContext) viewContext)
  {
    ArgumentNullException.ThrowIfNull((object) viewContext, nameof (viewContext));
    ArgumentNullException.ThrowIfNull((object) view, nameof (view));
    ArgumentNullException.ThrowIfNull((object) viewData, nameof (viewData));
    ArgumentNullException.ThrowIfNull((object) writer, nameof (writer));
    this.FormContext = viewContext.FormContext;
    this.ClientValidationEnabled = viewContext.ClientValidationEnabled;
    this.Html5DateRenderingMode = viewContext.Html5DateRenderingMode;
    this.ValidationSummaryMessageElement = viewContext.ValidationSummaryMessageElement;
    this.ValidationMessageElement = viewContext.ValidationMessageElement;
    this.CheckBoxHiddenInputRenderMode = viewContext.CheckBoxHiddenInputRenderMode;
    this.ExecutingFilePath = viewContext.ExecutingFilePath;
    this.View = view;
    this.ViewData = viewData;
    this.TempData = viewContext.TempData;
    this.Writer = writer;
    this._items = viewContext.Items;
  }

  public virtual FormContext FormContext
  {
    get => this._formContext;
    set
    {
      ArgumentNullException.ThrowIfNull((object) value, nameof (value));
      this._formContext = value;
    }
  }

  public bool ClientValidationEnabled { get; set; }

  public Html5DateRenderingMode Html5DateRenderingMode { get; set; }

  public string ValidationSummaryMessageElement { get; set; }

  public string ValidationMessageElement { get; set; }

  public CheckBoxHiddenInputRenderMode CheckBoxHiddenInputRenderMode { get; set; }

  public object ViewBag
  {
    get
    {
      if (this._viewBag == null)
        this._viewBag = new DynamicViewData((Func<ViewDataDictionary>) (() => this.ViewData));
      return (object) this._viewBag;
    }
  }

  public IView View { get; set; }

  public ViewDataDictionary ViewData { get; set; }

  public ITempDataDictionary TempData { get; set; }

  public TextWriter Writer { get; set; }

  public string? ExecutingFilePath { get; set; }

  internal Dictionary<object, object?> Items
  {
    get => this._items ?? (this._items = new Dictionary<object, object>());
  }

  public FormContext? GetFormContextForClientValidation()
  {
    return !this.ClientValidationEnabled ? (FormContext) null : this.FormContext;
  }

  #nullable disable
  private string DebuggerToString() => this.View?.Path ?? $"{{{this.GetType().FullName}}}";
}
