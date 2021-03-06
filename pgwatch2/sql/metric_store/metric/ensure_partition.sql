-- DROP FUNCTION IF EXISTS public.ensure_partition_metric(text);
-- select * from public.ensure_partition_metric('wal');

CREATE OR REPLACE FUNCTION admin.ensure_partition_metric(
    metric text
)
RETURNS void AS
/*
  creates a top level metric table if not already existing.
  expects the "metrics_template" table to exist.
*/
$SQL$
BEGIN
  
  IF NOT EXISTS (SELECT 1
                   FROM pg_tables
                  WHERE tablename = metric
                    AND schemaname = 'public')
  THEN
    --RAISE NOTICE 'creating partition % ...', metric;
   
    EXECUTE format($$CREATE TABLE IF NOT EXISTS public.%s (LIKE admin.metrics_template INCLUDING INDEXES)$$, quote_ident(metric));
    EXECUTE format($$COMMENT ON TABLE public.%s IS 'pgwatch2-generated-metric-lvl'$$, quote_ident(metric));
  END IF;

END;
$SQL$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION admin.ensure_partition_metric(text) TO pgwatch2;
