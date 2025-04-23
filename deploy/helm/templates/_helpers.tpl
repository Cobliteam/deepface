{{/* Get secrets from SSM for application container */}}
{{- define "ssmSecrets" -}}
{{- range .Values.appSsmSecrets }}
- name: {{ .environment_variable }}
  valueFrom:
    secretKeyRef:
      name: {{ $.Values.applicationName }}-secrets
      key: {{ .environment_variable | kebabcase }}
{{- end }}
{{- end }}

{{- define "selectorLabels" -}}
app.kubernetes.io/name: {{ .Values.applicationName }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "labels" -}}
tags.datadoghq.com/service: {{ .Values.applicationName }}
tags.datadoghq.com/version: {{ .Values.appImageVersion | quote }}
helm.sh/chart: {{ .Chart.Name }}
{{ include "selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if .Values.customLabels }}
{{- range $key, $value := .Values.customLabels }}
"{{ $key }}": "{{ $value }}"
{{- end }}
{{- end }}
{{- end }}

{{/* Convert k8s memory notations to bytes */}}
{{- define "memInBytes" -}}
  {{- $metricPrefixes := dict "K" 1e3 "M" 1e6 "G" 1e9 "T" 1e12 "P" 1e15 "E" 1e18 -}}
  {{- $binaryPrefixes := dict "Ki" 0x1p10 "Mi" 0x1p20 "Gi" 0x1p30 "Ti" 0x1p40 "Pi" 0x1p50 "Ei" 0x1p60 -}}
  {{- $prefixes := mustMerge $metricPrefixes $binaryPrefixes -}}
  {{- $baseValue := mustRegexFind "^[0-9]+" . -}}
  {{- $unitPrefix := regexFind "[EPTGMKei]+([0-9]+)?$" . -}}
  {{- if contains "e" $unitPrefix -}}
    {{- $exp := int (mustRegexFind "[0-9]+$" $unitPrefix) -}}
    {{- $multiplier :=  print "1" (repeat $exp "0") -}}
    {{- mul $baseValue $multiplier -}}
  {{- else if $unitPrefix -}}
    {{- mul $baseValue (get $prefixes $unitPrefix) -}}
  {{- else -}}
    {{ $baseValue }}
  {{- end -}}
{{- end -}}
