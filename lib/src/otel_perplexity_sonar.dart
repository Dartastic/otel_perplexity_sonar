// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

import 'otel_perplexity_sonar_suppression.dart';

const _tracerName = 'dartastic_otel_libs_perplexity_sonar';

Tracer _tracer() => OTel.tracerProvider().getTracer(_tracerName);

class PerplexitySonarResult {
  const PerplexitySonarResult({
    this.requestId,
    this.researchJobId,
    this.searchMode,
    this.recencyFilter,
    this.domainsAllowed,
    this.domainsBlocked,
    this.resultsReturned,
    this.sourcesCount,
    this.numSearchQueries,
    this.numReasoningSteps,
    this.researchStatus,
    this.creditsUsed,
    this.queryTokens,
    this.contextTokens,
    this.outputTokens,
    this.statusCode,
  });

  /// Sonar request id (for support/correlation).
  final String? requestId;

  /// Async research-job id (for `Sonar Deep Research` async API).
  final String? researchJobId;

  /// `web` / `academic` — Sonar's two top-level search modes.
  final String? searchMode;

  /// `hour` / `day` / `week` / `month` / `year` — Perplexity's
  /// recency filter.
  final String? recencyFilter;

  /// Comma-separated domain allowlist sent on the request.
  final String? domainsAllowed;

  /// Comma-separated domain blocklist sent on the request.
  final String? domainsBlocked;

  /// Top-level result count returned to the caller.
  final int? resultsReturned;

  /// Total distinct source URLs cited across results.
  final int? sourcesCount;

  /// For Deep Research: number of sub-queries Sonar issued.
  final int? numSearchQueries;

  /// For Deep Research: number of reasoning steps executed.
  final int? numReasoningSteps;

  /// `queued` / `in_progress` / `completed` / `failed` /
  /// `timed_out` — async Deep Research only.
  final String? researchStatus;

  /// Sonar's billing unit (Sonar/Sonar-Pro/Sonar Deep Research price
  /// per request + per source citation + per output token).
  final int? creditsUsed;

  /// Token counts surfaced when present.
  final int? queryTokens;
  final int? contextTokens;
  final int? outputTokens;

  final int? statusCode;
}

class PerplexitySonarCallResult<T> {
  const PerplexitySonarCallResult({required this.value, this.result});
  final T value;
  final PerplexitySonarResult? result;
}

/// Wraps a Perplexity Sonar Search / Deep Research API call in a
/// CLIENT span. [operation] is one of `search`, `search.academic`,
/// `deep_research`, `deep_research.async.create`,
/// `deep_research.async.get`, `deep_research.async.cancel`.
Future<T> tracedPerplexitySonar<T>({
  required String operation,
  required Future<PerplexitySonarCallResult<T>> Function() invoke,
}) async {
  if (perplexitySonarInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final m = <String, Object>{
    'rpc.system': 'perplexity_sonar',
    'rpc.method': operation,
    'perplexity_sonar.operation': operation,
  };

  final span = _tracer().startSpan(
    'perplexity_sonar $operation',
    kind: SpanKind.client,
    attributes: OTel.attributesFromMap(m),
  );
  try {
    final r = await invoke();
    if (r.result != null) {
      final extras = <Attribute<Object>>[];
      if (r.result!.requestId != null) {
        extras.add(OTel.attributeString(
          'perplexity_sonar.request.id',
          r.result!.requestId!,
        ));
      }
      if (r.result!.researchJobId != null) {
        extras.add(OTel.attributeString(
          'perplexity_sonar.research_job.id',
          r.result!.researchJobId!,
        ));
      }
      if (r.result!.searchMode != null) {
        extras.add(OTel.attributeString(
          'perplexity_sonar.search.mode',
          r.result!.searchMode!,
        ));
      }
      if (r.result!.recencyFilter != null) {
        extras.add(OTel.attributeString(
          'perplexity_sonar.recency.filter',
          r.result!.recencyFilter!,
        ));
      }
      if (r.result!.domainsAllowed != null) {
        extras.add(OTel.attributeString(
          'perplexity_sonar.domains.allowed',
          r.result!.domainsAllowed!,
        ));
      }
      if (r.result!.domainsBlocked != null) {
        extras.add(OTel.attributeString(
          'perplexity_sonar.domains.blocked',
          r.result!.domainsBlocked!,
        ));
      }
      if (r.result!.resultsReturned != null) {
        extras.add(OTel.attributeInt(
          'perplexity_sonar.results.returned',
          r.result!.resultsReturned!,
        ));
      }
      if (r.result!.sourcesCount != null) {
        extras.add(OTel.attributeInt(
          'perplexity_sonar.sources.count',
          r.result!.sourcesCount!,
        ));
      }
      if (r.result!.numSearchQueries != null) {
        extras.add(OTel.attributeInt(
          'perplexity_sonar.search_queries.count',
          r.result!.numSearchQueries!,
        ));
      }
      if (r.result!.numReasoningSteps != null) {
        extras.add(OTel.attributeInt(
          'perplexity_sonar.reasoning_steps.count',
          r.result!.numReasoningSteps!,
        ));
      }
      if (r.result!.researchStatus != null) {
        extras.add(OTel.attributeString(
          'perplexity_sonar.research.status',
          r.result!.researchStatus!,
        ));
        if (r.result!.researchStatus == 'failed' ||
            r.result!.researchStatus == 'timed_out') {
          span.setStatus(
            SpanStatusCode.Error,
            'Sonar research ${r.result!.researchStatus}',
          );
        }
      }
      if (r.result!.creditsUsed != null) {
        extras.add(OTel.attributeInt(
          'perplexity_sonar.credits.used',
          r.result!.creditsUsed!,
        ));
      }
      if (r.result!.queryTokens != null) {
        extras.add(OTel.attributeInt(
          'perplexity_sonar.tokens.query',
          r.result!.queryTokens!,
        ));
      }
      if (r.result!.contextTokens != null) {
        extras.add(OTel.attributeInt(
          'perplexity_sonar.tokens.context',
          r.result!.contextTokens!,
        ));
      }
      if (r.result!.outputTokens != null) {
        extras.add(OTel.attributeInt(
          'perplexity_sonar.tokens.output',
          r.result!.outputTokens!,
        ));
      }
      if (r.result!.statusCode != null) {
        extras.add(OTel.attributeInt(
          'http.response.status_code',
          r.result!.statusCode!,
        ));
        if (r.result!.statusCode! >= 400) {
          span.setStatus(
            SpanStatusCode.Error,
            'Sonar HTTP ${r.result!.statusCode}',
          );
        }
      }
      if (extras.isNotEmpty) span.addAttributes(OTel.attributes(extras));
    }
    return r.value;
  } catch (e, st) {
    span.addAttributes(OTel.attributes([
      OTel.attributeString(
        ErrorResource.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
