/// Create / edit form page for Gisila Studio.
library gisila_studio.ui.form_page;

import '../column_info.dart';
import '../model_admin.dart';
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

    fieldBlocks.write(_buildField(
      name: colName,
      label: _humanize(colName),
      info: info,
      isReadonly: isReadonly,
      isRequired: isRequired,
      currentValue: currentValue,
      hasError: hasError,
      errorMsg: fieldErrors[colName],
    ));
  }

  final pageTitle = isAdd ? 'New ${admin.displayName}' : _rowTitle(existingRow, admin);
  final subtitle = isAdd
      ? 'Fill in the details to create a new ${admin.displayName.toLowerCase()}.'
      : 'Update the fields below and save your changes.';

  final deleteMeta = !isAdd
      ? '<a class="form-footer-link danger" href="$prefix/$table/${Uri.encodeComponent(pkValue!)}/delete/">Delete this record</a>'
      : '';

  final extraAction = isAdd
      ? '<a class="form-footer-link" href="#" onclick="document.getElementById(\'_act\').value=\'save_add\';document.getElementById(\'rec-form\').submit();return false">save and create another</a>'
      : '<a class="form-footer-link" href="#" onclick="document.getElementById(\'_act\').value=\'save_continue\';document.getElementById(\'rec-form\').submit();return false">save and keep editing</a>';

  final body = '''
    <div class="page-hdr">
      <div class="page-title">${_esc(pageTitle)}</div>
      <div class="page-meta">$subtitle</div>
    </div>

    <form method="post" action="$formAction" id="rec-form" class="form-wrap">
      <input type="hidden" name="_action" value="save" id="_act">
      <div class="form-card">
        <div class="form-card-title">${_esc(admin.displayName)} details</div>
        $fieldBlocks
      </div>

      <div class="form-footer">
        <div class="form-footer-left">
          <a class="btn btn-secondary btn-sm" href="$prefix/$table/">Cancel</a>
          $deleteMeta
        </div>
        <div class="form-footer-right">
          $extraAction
          <button class="btn btn-primary" type="submit">Save</button>
        </div>
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
  required Object? currentValue,
  required bool hasError,
  String? errorMsg,
}) {
  final inputType = info?.inputType ?? 'text';
  final prefilledStr = info?.formValue(currentValue) ?? (currentValue?.toString() ?? '');

  final req = isRequired ? '<span class="req">*</span>' : '';
  final errorHtml = hasError && errorMsg != null
      ? '<div class="field-error">${_esc(errorMsg)}</div>'
      : '';

  String inputHtml;
  if (isReadonly) {
    inputHtml = '<div class="readonly-val">${_esc(prefilledStr.isEmpty ? '—' : prefilledStr)}</div>';
  } else if (inputType == 'checkbox') {
    final checked = currentValue == true || currentValue == 'true' || currentValue == 1
        ? ' checked'
        : '';
    inputHtml = '<div class="checkbox-row">'
        '<input type="checkbox" id="f_$name" name="$name"$checked>'
        '<label for="f_$name">Enabled</label>'
        '</div>';
  } else if (inputType == 'textarea') {
    inputHtml = '<textarea name="$name" id="f_$name" rows="4">${_esc(prefilledStr)}</textarea>';
  } else {
    final step = inputType == 'number_decimal' ? ' step="any"' : '';
    final type = inputType == 'number_decimal' ? 'number' : inputType;
    inputHtml = '<input type="$type" name="$name" id="f_$name"'
        '${isRequired ? ' required' : ''} value="${_esc(prefilledStr)}"$step>';
  }

  // Hint for FK columns
  final hint = info != null && info.dataType.isNotEmpty && !isReadonly
      ? '<div class="field-hint">${_esc(info.dataType)}${info.isNullable ? ' · optional' : ''}</div>'
      : '';

  return '''
    <div class="field${hasError ? ' has-error' : ''}">
      <label class="field-lbl" for="f_$name">${_esc(label)}$req</label>
      $inputHtml
      $hint
      $errorHtml
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
