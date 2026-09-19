import type { QueryResult, QueryResultRow } from 'pg';

/** The caller chooses the meaning of an empty RETURNING result. */
export function returnedRow<T extends QueryResultRow>(result: Pick<QueryResult<T>, 'rows'>, missingCode: string): T {
  const row = result.rows[0];
  if (!row) throw new Error(missingCode);
  return row;
}
