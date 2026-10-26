/// Create / edit form page for Gisila Studio.
library gisila_studio.ui.form_page;

import '../column_info.dart';
import '../model_admin.dart';
import 'icons.dart';
import 'layout.dart';

/// Renders the add or edit form for a model.
String renderFormPage({
  required ModelAdmin<dynamic> admin,
  required List<ModelAdmin<dynamic>> allAdmins,
  required List<ColumnInfo> columns,
  required Map<String, int> modelCounts,
  required String prefix,
  required String studioTitle,
  Map<String, dynamic>? existingRow,
  String? pkValue,
  Map<String, String> fieldErrors = const {},
  String? flashMessage,
  bool flashIsError = false,
  bool showLogout = false,
}) {
  final table = admin.meta.tableName;
  final isAdd = existingRow == null;
  final formAction = isAdd
      ? '$prefix/$table/add/'
      : '$prefix/$table/${Uri.encodeComponent(pkValue!)}/change/';

  final colInfoMap = {for (final c in columns) c.name: c};

  final fieldBlocks = StringBuffer();
  for (final colName in admin.meta.columnNames) {
    if (!admin.isOnForm(colName)) continue;
    final info = colInfoMap[colName];
    final isReadonly = admin.readonlyFields.contains(colName);
    final isRequired = !(info?.isNullable ?? true) &&
        (info?.columnDefault == null) &&
        !isReadonly;
    final currentValue = existingRow?[colName];
    final hasError = fieldErrors.containsKey(colName);

    final isPassword = admin.passwordFields.contains(colName);
    fieldBlocks.write(_buildField(
      name: colName,
      label: _humanize(colName),
      info: info,
      isReadonly: isReadonly,
      isRequired: isRequired,
      isPassword: isPassword,
      currentValue: currentValue,
      hasError: hasError,
      errorMsg: fieldErrors[colName],
    ));
  }

  final pageTitle =
      isAdd ? 'New ${admin.displayName}' : _rowTitle(existingRow, admin);
  final subtitle = isAdd
      ? 'Fill in the details to create a new ${admin.displayName.toLowerCase()}.'
      : 'Update the fields below and save your changes.';

  final deleteLink = !isAdd
      ? '<a class="btn btn-danger-ghost btn-md" href="$prefix/$table/${Uri.encodeComponent(pkValue!)}/delete/">Delete ${_esc(admin.displayName.toLowerCase())}${icon('trash')}</a>'
      : '';

  final (extraValue, extraLabel) = isAdd
      ? ('save_add', 'Save and add another')
      : ('save_continue', 'Save and keep editing');

  final body = '''
    <div class="page-hdr">
      <h1 class="page-title">${_esc(pageTitle)}</h1>
      <p class="page-meta">$subtitle</p>
    </div>

    <form method="post" action="$formAction" id="rec-form" class="form-wrap">
      <input type="hidden" name="_action" value="save" id="_act">
      <div class="form-card">
        <div class="form-card-body">
          <h2 class="form-card-title">${_esc(admin.displayName)} details</h2>
          $fieldBlocks
        </div>
        <div class="btn-set">
          <a class="btn btn-secondary" href="$prefix/$table/">Cancel</a>
          <button class="btn btn-primary" type="submit">Save</button>
        </div>
      </div>

      <div class="form-secondary">
        <button class="btn btn-ghost btn-md" type="submit" onclick="document.getElementById('_act').value='$extraValue'">$extraLabel</button>
        $deleteLink
      </div>
    </form>''';

  return renderLayout(
    title: isAdd ? 'New ${admin.displayName}' : admin.displayName,
    body: body,
    prefix: prefix,
    admins: allAdmins,
    modelCounts: modelCounts,
    activeTable: table,
    studioTitle: studioTitle,
    topbarBreadcrumbs: [
      (admin.displayNamePlural, '$prefix/$table/'),
      (isAdd ? 'New' : pageTitle, null),
    ],
    flashMessage: flashMessage,
    flashIsError: flashIsError,
    showLogout: showLogout,
  );
}

String _buildField({
  required String name,
  required String label,
  required ColumnInfo? info,
  required bool isReadonly,
  required bool isRequired,
  required bool isPassword,
  required Object? currentValue,
  required bool hasError,
  String? errorMsg,
}) {
  final inputType = isPassword ? 'password' : (info?.inputType ?? 'text');
  // Never pre-fill password fields — avoids leaking hashes into the DOM.
  final prefilledStr = isPassword
      ? ''
      : (info?.formValue(currentValue) ?? (currentValue?.toString() ?? ''));

  final req = isRequired ? '<span class="req">*</span>' : '';
  final errorHtml = hasError && errorMsg != null
      ? '<div class="field-error" id="e_$name">${_esc(errorMsg)}</div>'
      : '';

  final invalid =
      hasError ? ' aria-invalid="true" aria-describedby="e_$name"' : '';

  String inputHtml;
  if (isReadonly) {
    inputHtml =
        '<div class="readonly-val">${_esc(prefilledStr.isEmpty ? '—' : prefilledStr)}</div>';
  } else if (inputType == 'checkbox') {
    final checked =
        currentValue == true || currentValue == 'true' || currentValue == 1
            ? ' checked'
            : '';
    inputHtml = '<div class="checkbox-row">'
        '<input type="checkbox" id="f_$name" name="$name"$checked>'
        '<label for="f_$name">Enabled</label>'
        '</div>';
  } else if (inputType == 'textarea') {
    inputHtml =
        '<textarea name="$name" id="f_$name" rows="4"$invalid>${_esc(prefilledStr)}</textarea>';
  } else {
    final step = inputType == 'number_decimal' ? ' step="any"' : '';
    final type = inputType == 'number_decimal' ? 'number' : inputType;
    inputHtml = '<input type="$type" name="$name" id="f_$name"'
        '${isRequired ? ' required' : ''} value="${_esc(prefilledStr)}"$step$invalid>';
  }

  // Hint for FK columns
  final hint = info != null && info.dataType.isNotEmpty && !isReadonly
      ? '<div class="field-hint">${_esc(info.dataType)}${info.isNullable ? ' · optional' : ''}</div>'
      : '';

  return '''
    <div class="field${hasError ? ' has-error' : ''}">
      <label class="field-lbl" for="f_$name">${_esc(label)}$req</label>
      <div class="field-input">
        $inputHtml
        ${hasError && !isReadonly && inputType != 'checkbox' ? icon('warning-filled', cls: 'field-error-icon') : ''}
      </div>
      ${hasError ? errorHtml : hint}
    </div>''';
}

String _rowTitle(Map<String, dynamic>? row, ModelAdmin<dynamic> admin) {
  if (row == null) return 'Edit';
  for (final col in admin.effectiveListDisplay) {
    if (col == admin.meta.primaryKey) continue;
    final val = row[col];
    if (val != null && val.toString().isNotEmpty) return val.toString();
  }
  return row[admin.meta.primaryKey]?.toString() ?? 'Edit';
}

String _esc(String s) => s
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');

String _humanize(String snake) => snake
    .split('_')
    .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
    .join(' ');
