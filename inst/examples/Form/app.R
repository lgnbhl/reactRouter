# Dashboard Form Example
# Demonstrates Form component in a dashboard context:
#   - GET form to search KPIs by name or category (updates URL search params, triggers loader)
#   - POST form to generate a report by metric and date range (triggers action, result via useActionData)
#   - useNavigation to show "submitting" / "loading" state

library(reactRouter)
library(htmltools)

ui <- RouterProvider(
  Route(
    path = "/",
    element = div(
      style = "max-width: 640px; margin: 0 auto; padding: 20px; font-family: system-ui;",
      tags$h2("Form Example"),
      tags$p(
        style = "color: gray;",
        "Navigation state: ",
        useNavigation(tags$strong(), selector = "state")
      ),
      tags$nav(tags$ul(
        tags$li(NavLink(to = "/", "Home")),
        tags$li(NavLink(to = "/search", "Search Metrics (GET)")),
        tags$li(NavLink(to = "/report", "Report (POST)"))
      )),
      tags$hr(),
      Outlet()
    ),

    # -- Index route ---
    Route(
      index = TRUE,
      element = div(
        tags$p("This example demonstrates the Form component."),
        tags$ul(
          tags$li(
            tags$strong("Search Metrics (GET)"),
            " — search dashboard KPIs by name or category; updates URL search params and triggers a loader."
          ),
          tags$li(
            tags$strong("Report (POST)"),
            " — generate a dashboard report by metric and date range; triggers a route action, result shown via useActionData."
          )
        )
      )
    ),

    # -- GET form: search metrics with loader ---
    Route(
      path = "search",
      loader = JS(
        "({ request }) => {
            const metrics = [
              { name: 'Revenue',         category: 'Finance',   value: '$142,500', trend: '+12.3%' },
              { name: 'Operating Costs',  category: 'Finance',   value: '$87,200',  trend: '+3.1%' },
              { name: 'Net Profit',       category: 'Finance',   value: '$55,300',  trend: '+18.7%' },
              { name: 'Active Users',     category: 'Engagement', value: '8,320',   trend: '+5.1%' },
              { name: 'New Signups',      category: 'Engagement', value: '1,204',   trend: '+22.0%' },
              { name: 'Churn Rate',       category: 'Engagement', value: '2.4%',    trend: '-0.8%' },
              { name: 'Page Views',       category: 'Traffic',   value: '214,700',  trend: '-2.4%' },
              { name: 'Bounce Rate',      category: 'Traffic',   value: '38.2%',    trend: '-1.5%' },
              { name: 'Avg Session Time', category: 'Traffic',   value: '4m 12s',   trend: '+8.6%' }
            ];

            const url   = new URL(request.url);
            const q     = (url.searchParams.get('q') || '').trim();
            if (!q) return { results: '', query: '', count: 0 };

            const lower = q.toLowerCase();
            const hits  = metrics.filter(m =>
              m.name.toLowerCase().includes(lower) ||
              m.category.toLowerCase().includes(lower)
            );

            const summary = hits.map(m => m.name + '  |  ' + m.category + '  |  ' + m.value + '  (' + m.trend + ')').join('\\n');
            return { results: summary, query: q, count: hits.length };
          }"
      ),
      element = div(
        tags$h3("Search Metrics (GET)"),
        tags$p(
          style = "color: gray; font-size: 0.9em;",
          "The Form uses ",
          tags$code("method=\"get\""),
          " so submitting updates the URL to ",
          tags$code("?q=..."),
          " and triggers the route loader."
        ),
        Form(
          method = "get",
          style = "display: flex; gap: 8px; margin-bottom: 16px;",
          tags$input(
            type = "search",
            name = "q",
            placeholder = "e.g. revenue, traffic, engagement...",
            style = "flex: 1; padding: 8px; border: 1px solid #ccc; border-radius: 4px;"
          ),
          tags$button(
            type = "submit",
            style = "padding: 8px 16px; border: none; background: #0d6efd; color: white; border-radius: 4px; cursor: pointer;",
            "Search"
          )
        ),
        tags$div(
          style = "background: #f8f9fa; padding: 12px; border-radius: 6px; margin-bottom: 12px;",
          tags$span(style = "color: gray;", "Query: "),
          useSearchParams(tags$strong(), param = "q"),
          tags$span(style = "color: gray; margin-left: 16px;", "Results: "),
          useLoaderData(tags$strong(), selector = "count")
        ),
        tags$pre(
          style = "background: #f5f5f5; padding: 10px; white-space: pre-wrap;",
          useLoaderData(tags$span(), selector = "results")
        )
      )
    ),

    # -- POST form: dashboard report generator ---
    Route(
      path = "report",
      action = JS(
        "async ({ request }) => {
            const fd     = await request.formData();
            const metric = fd.get('metric');
            const from   = fd.get('from');
            const to     = fd.get('to');
            const grain  = fd.get('granularity') || 'daily';

            await new Promise(r => setTimeout(r, 800));

            const totals = { Revenue: '$142,500', Users: '8,320', 'Page Views': '214,700' };
            const avgs   = { Revenue: '$4,750/day', Users: '277/day', 'Page Views': '7,157/day' };
            const trends = { Revenue: '+12.3%', Users: '+5.1%', 'Page Views': '-2.4%' };

            return {
              metric: metric,
              period: from + ' to ' + to,
              granularity: grain,
              total: totals[metric] || 'N/A',
              average: avgs[metric] || 'N/A',
              trend: trends[metric] || 'N/A'
            };
          }"
      ),
      element = div(
        tags$h3("Generate Report (POST)"),
        tags$p(
          style = "color: gray; font-size: 0.9em;",
          "The Form uses ",
          tags$code("method=\"post\""),
          " so submitting triggers the route ",
          tags$code("action"),
          ". The result is available via useActionData."
        ),
        Form(
          method = "post",
          style = "display: flex; flex-direction: column; gap: 10px; max-width: 400px; margin-bottom: 16px;",
          tags$label(
            "Metric",
            tags$select(
              name = "metric",
              style = "display: block; width: 100%; padding: 8px; border: 1px solid #ccc; border-radius: 4px; margin-top: 4px;",
              tags$option(value = "Revenue", "Revenue"),
              tags$option(value = "Users", "Active Users"),
              tags$option(value = "Page Views", "Page Views")
            )
          ),
          tags$label(
            "From",
            tags$input(
              type = "date",
              name = "from",
              value = "2026-01-01",
              required = NA,
              style = "display: block; width: 100%; padding: 8px; border: 1px solid #ccc; border-radius: 4px; margin-top: 4px;"
            )
          ),
          tags$label(
            "To",
            tags$input(
              type = "date",
              name = "to",
              value = "2026-03-31",
              required = NA,
              style = "display: block; width: 100%; padding: 8px; border: 1px solid #ccc; border-radius: 4px; margin-top: 4px;"
            )
          ),
          tags$fieldset(
            style = "border: 1px solid #ccc; border-radius: 4px; padding: 8px;",
            tags$legend("Granularity"),
            tags$label(
              style = "margin-right: 12px;",
              tags$input(
                type = "radio",
                name = "granularity",
                value = "daily",
                checked = NA
              ),
              " Daily"
            ),
            tags$label(
              style = "margin-right: 12px;",
              tags$input(
                type = "radio",
                name = "granularity",
                value = "weekly"
              ),
              " Weekly"
            ),
            tags$label(
              tags$input(
                type = "radio",
                name = "granularity",
                value = "monthly"
              ),
              " Monthly"
            )
          ),
          tags$button(
            type = "submit",
            style = "padding: 10px 20px; border: none; background: #198754; color: white; border-radius: 4px; cursor: pointer; align-self: flex-start;",
            "Generate Report"
          )
        ),
        tags$h4("Report Summary:"),
        tags$div(
          style = "background: #f8f9fa; padding: 12px; border-radius: 6px; margin-bottom: 8px;",
          tags$p(
            tags$strong("Metric: "),
            useActionData(into = tags$span(), selector = "metric")
          ),
          tags$p(
            tags$strong("Period: "),
            useActionData(into = tags$span(), selector = "period")
          ),
          tags$p(
            tags$strong("Granularity: "),
            useActionData(into = tags$span(), selector = "granularity")
          ),
          tags$p(
            tags$strong("Total: "),
            useActionData(into = tags$span(), selector = "total")
          ),
          tags$p(
            tags$strong("Average: "),
            useActionData(into = tags$span(), selector = "average")
          ),
          tags$p(
            tags$strong("Trend: "),
            useActionData(into = tags$span(), selector = "trend")
          )
        )
      )
    )
  )
)

# htmltools::save_html(ui, "index.html")
htmltools::browsable(ui)
