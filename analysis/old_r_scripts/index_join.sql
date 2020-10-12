CREATE INDEX "main"."pptidx"
ON "ppt" (
  "lon" ASC,
  "lat" ASC,
  "month" ASC
);


CREATE INDEX "main"."tminidx"
ON "tmin" (
  "lon" ASC,
  "lat" ASC,
  "month" ASC
);

CREATE INDEX "main"."sradidx"
ON "srad" (
  "lon" ASC,
  "lat" ASC,
  "month" ASC
);

CREATE VIEW climate
AS
SELECT
	tmin.lat AS lat,
	tmin.lon AS lon,
	tmin.month AS month,
	ppt.ppt AS ppt,
	srad.srad AS srad,
	tmin.tmin AS tmin
FROM
	ppt
	INNER JOIN
	srad
	ON
		ppt.lon = srad.lon AND
		ppt.lat = srad.lat AND
		ppt.time = srad.time
	INNER JOIN
	tmin
	ON
		(
			ppt.lat = tmin.lat AND
			ppt.lon = tmin.lon AND
			ppt.time = tmin.time
		)

CREATE INDEX "main"."climateidx"
ON "climate" (
  "lon" ASC,
  "lat" ASC,
  "month" ASC
);
