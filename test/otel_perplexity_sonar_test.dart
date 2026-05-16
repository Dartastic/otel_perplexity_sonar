// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_perplexity_sonar/otel_perplexity_sonar.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness = await maybeInitializeOtelForTest(
      serviceName: 'otel_perplexity_sonar-test',
    );
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('search records mode + recency + sources + credits', () async {
    await tracedPerplexitySonar<String>(
      operation: 'search',
      invoke: () async => const PerplexitySonarCallResult(
        value: 'ok',
        result: PerplexitySonarResult(
          requestId: 'req_1',
          searchMode: 'web',
          recencyFilter: 'week',
          domainsAllowed: 'docs.flutter.dev,api.flutter.dev',
          resultsReturned: 10,
          sourcesCount: 32,
          creditsUsed: 1,
          queryTokens: 80,
          outputTokens: 0,
          statusCode: 200,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('perplexity_sonar search')!);
    expect(a['perplexity_sonar.search.mode'], 'web');
    expect(a['perplexity_sonar.recency.filter'], 'week');
    expect(a['perplexity_sonar.domains.allowed'],
        'docs.flutter.dev,api.flutter.dev');
    expect(a['perplexity_sonar.sources.count'], 32);
    expect(a['perplexity_sonar.credits.used'], 1);
  });

  test('deep_research records queries + reasoning steps', () async {
    await tracedPerplexitySonar<String>(
      operation: 'deep_research',
      invoke: () async => const PerplexitySonarCallResult(
        value: 'ok',
        result: PerplexitySonarResult(
          researchJobId: 'job_1',
          searchMode: 'web',
          numSearchQueries: 28,
          numReasoningSteps: 14,
          sourcesCount: 95,
          contextTokens: 12000,
          outputTokens: 4500,
          creditsUsed: 25,
          researchStatus: 'completed',
          statusCode: 200,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('perplexity_sonar deep_research')!);
    expect(a['perplexity_sonar.search_queries.count'], 28);
    expect(a['perplexity_sonar.reasoning_steps.count'], 14);
    expect(a['perplexity_sonar.credits.used'], 25);
    expect(a['perplexity_sonar.research.status'], 'completed');
  });

  test('timed_out research sets span error', () async {
    await tracedPerplexitySonar<String>(
      operation: 'deep_research.async.get',
      invoke: () async => const PerplexitySonarCallResult(
        value: 'ok',
        result: PerplexitySonarResult(
          researchJobId: 'job_2',
          researchStatus: 'timed_out',
        ),
      ),
    );
    expect(
      spans.findSpanByName('perplexity_sonar deep_research.async.get')!.status,
      SpanStatusCode.Error,
    );
  });

  test('suppression skips spans', () async {
    await runWithoutPerplexitySonarInstrumentationAsync(() async {
      await tracedPerplexitySonar<String>(
        operation: 'search',
        invoke: () async => const PerplexitySonarCallResult(value: 'v'),
      );
    });
    expect(spans.findSpansStartingWith('perplexity_sonar '), isEmpty);
  });
}
