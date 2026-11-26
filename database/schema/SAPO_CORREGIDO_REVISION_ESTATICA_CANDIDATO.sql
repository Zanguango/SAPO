BEGIN;

-- =========================================================
-- SAPO - SISTEMA AVANZADO POLICIAL OPERATIVO
-- BLOQUE 1: ORGANIZACION, UNIDADES, PERFILES Y USUARIOS
-- PostgreSQL
-- =========================================================

CREATE EXTENSION IF NOT EXISTS btree_gist;

-- =========================================================
-- 1. ORGANIZACION
-- =========================================================

CREATE TABLE ORGANIZACION (
    id_organizacion BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_creacion TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_organizacion_nombre
        UNIQUE (nombre)
);

-- =========================================================
-- 2. UNIDAD ORGANIZATIVA
-- =========================================================

CREATE TABLE UNIDAD_ORGANIZATIVA (
    id_unidad BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_organizacion BIGINT NOT NULL,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_creacion TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_unidad_organizacion
        FOREIGN KEY (id_organizacion)
        REFERENCES ORGANIZACION(id_organizacion),

    CONSTRAINT uq_unidad_nombre_organizacion
        UNIQUE (id_organizacion, nombre),

    CONSTRAINT uq_unidad_id_organizacion
        UNIQUE (id_unidad, id_organizacion)
);

-- =========================================================
-- 3. PERFIL
-- =========================================================

CREATE TABLE PERFIL (
    id_perfil BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    codigo VARCHAR(50) NOT NULL UNIQUE,
    descripcion VARCHAR(250),
    protegido BOOLEAN NOT NULL DEFAULT FALSE,
    activo BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT ck_perfil_codigo
        CHECK (codigo = UPPER(BTRIM(codigo)))
);

INSERT INTO PERFIL (codigo, descripcion, protegido)
VALUES
    ('ADMINISTRADOR', 'Administración global del sistema', TRUE),
    ('SUPERVISOR', 'Supervisión de la organización', TRUE),
    ('AGENTE', 'Operativa policial dentro del ámbito asignado', TRUE);

-- =========================================================
-- 4. USUARIO
-- =========================================================

CREATE TABLE USUARIO (
    id_usuario BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    username VARCHAR(80) NOT NULL,
    email VARCHAR(254) NOT NULL,
    password_hash TEXT NOT NULL,

    intentos_fallidos INTEGER NOT NULL DEFAULT 0,
    bloqueado_hasta TIMESTAMPTZ,
    auth_version INTEGER NOT NULL DEFAULT 1,

    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_creacion TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_modificacion TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT ck_usuario_intentos
        CHECK (intentos_fallidos >= 0),

    CONSTRAINT ck_usuario_auth_version
        CHECK (auth_version >= 1),

    CONSTRAINT ck_usuario_username
        CHECK (username = BTRIM(username) AND username <> ''),

    CONSTRAINT ck_usuario_email
        CHECK (email = BTRIM(email) AND email <> '')
);

CREATE UNIQUE INDEX uq_usuario_username_normalizado
ON USUARIO (LOWER(BTRIM(username)));

CREATE UNIQUE INDEX uq_usuario_email_normalizado
ON USUARIO (LOWER(BTRIM(email)));

-- =========================================================
-- 5. HISTORIAL DE PERTENENCIA ORGANIZATIVA
-- =========================================================

CREATE TABLE HISTORIAL_PERTENENCIA_ORGANIZATIVA (
    id_historial BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_usuario BIGINT NOT NULL,
    id_organizacion BIGINT NOT NULL,
    fecha_inicio TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_fin TIMESTAMPTZ,

    CONSTRAINT fk_pert_usuario
        FOREIGN KEY (id_usuario)
        REFERENCES USUARIO(id_usuario),

    CONSTRAINT fk_pert_organizacion
        FOREIGN KEY (id_organizacion)
        REFERENCES ORGANIZACION(id_organizacion),

    CONSTRAINT ck_pert_fechas
        CHECK (
            fecha_fin IS NULL
            OR fecha_fin > fecha_inicio
        ),

    CONSTRAINT ex_pert_usuario_periodo
        EXCLUDE USING GIST (
            id_usuario WITH =,
            tstzrange(fecha_inicio, fecha_fin, '[)') WITH &&
        )
);

-- =========================================================
-- 6. HISTORIAL DE UNIDAD DEL USUARIO
-- =========================================================

CREATE TABLE HISTORIAL_UNIDAD_USUARIO (
    id_historial_unidad BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_historial BIGINT NOT NULL,
    id_unidad BIGINT NOT NULL,
    fecha_inicio TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_fin TIMESTAMPTZ,

    CONSTRAINT fk_hist_unidad_pertenencia
        FOREIGN KEY (id_historial)
        REFERENCES HISTORIAL_PERTENENCIA_ORGANIZATIVA(id_historial),

    CONSTRAINT fk_hist_unidad_unidad
        FOREIGN KEY (id_unidad)
        REFERENCES UNIDAD_ORGANIZATIVA(id_unidad),

    CONSTRAINT ck_hist_unidad_fechas
        CHECK (
            fecha_fin IS NULL
            OR fecha_fin > fecha_inicio
        ),

    CONSTRAINT ex_hist_unidad_periodo
        EXCLUDE USING GIST (
            id_historial WITH =,
            tstzrange(fecha_inicio, fecha_fin, '[)') WITH &&
        )
);

-- =========================================================
-- 7. HISTORIAL DE PERFILES DEL USUARIO
-- =========================================================

CREATE TABLE HISTORIAL_PERFIL_USUARIO (
    id_historial_perfil BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_usuario BIGINT NOT NULL,
    id_perfil BIGINT NOT NULL,
    fecha_inicio TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_fin TIMESTAMPTZ,

    CONSTRAINT fk_hist_perfil_usuario
        FOREIGN KEY (id_usuario)
        REFERENCES USUARIO(id_usuario),

    CONSTRAINT fk_hist_perfil_perfil
        FOREIGN KEY (id_perfil)
        REFERENCES PERFIL(id_perfil),

    CONSTRAINT ck_hist_perfil_fechas
        CHECK (
            fecha_fin IS NULL
            OR fecha_fin > fecha_inicio
        ),

    CONSTRAINT ex_hist_perfil_periodo
        EXCLUDE USING GIST (
            id_usuario WITH =,
            id_perfil WITH =,
            tstzrange(fecha_inicio, fecha_fin, '[)') WITH &&
        )
);

-- =========================================================
-- FIN DEL BLOQUE 1
-- =========================================================

-- =========================================================
-- 8. PERSONA
-- =========================================================

CREATE TABLE PERSONA (
    id_persona BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    dni VARCHAR(20) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    apellidos VARCHAR(150) NOT NULL,
    fecha_nacimiento DATE,
    telefono VARCHAR(30),
    email VARCHAR(254),
    domicilio TEXT,
    observaciones TEXT,

    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_creacion TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_modificacion TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT ck_persona_dni
        CHECK (dni = BTRIM(dni) AND dni <> '')
);

CREATE UNIQUE INDEX uq_persona_dni_normalizado
ON PERSONA (UPPER(BTRIM(dni)));

-- =========================================================
-- 9. TIPO_ANTECEDENTE
-- =========================================================

CREATE TABLE TIPO_ANTECEDENTE (
    id_tipo_antecedente BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(120) NOT NULL,
    descripcion TEXT,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_creacion TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX uq_tipo_antecedente_nombre
ON TIPO_ANTECEDENTE (LOWER(BTRIM(nombre)));

-- =========================================================
-- 10. ANTECEDENTE
-- =========================================================

CREATE TABLE ANTECEDENTE (
    id_antecedente BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_persona BIGINT NOT NULL,
    id_tipo_antecedente BIGINT NOT NULL,

    descripcion TEXT NOT NULL,
    estado VARCHAR(20) NOT NULL DEFAULT 'PENDIENTE',

    fecha_registro TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_modificacion TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    activo BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_antecedente_persona
        FOREIGN KEY (id_persona)
        REFERENCES PERSONA(id_persona),

    CONSTRAINT fk_antecedente_tipo
        FOREIGN KEY (id_tipo_antecedente)
        REFERENCES TIPO_ANTECEDENTE(id_tipo_antecedente),

    CONSTRAINT ck_antecedente_estado
        CHECK (estado IN ('PENDIENTE', 'VIGENTE', 'ANULADO'))
);

-- =========================================================
-- 11. TIPO_INCIDENTE
-- =========================================================

CREATE TABLE TIPO_INCIDENTE (
    id_tipo_incidente BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(120) NOT NULL,
    descripcion TEXT,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_creacion TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX uq_tipo_incidente_nombre
ON TIPO_INCIDENTE (LOWER(BTRIM(nombre)));

-- =========================================================
-- 12. ESTADO_INCIDENTE
-- =========================================================

CREATE TABLE ESTADO_INCIDENTE (
    id_estado_incidente BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    codigo VARCHAR(50) NOT NULL,
    descripcion VARCHAR(200) NOT NULL,
    orden_visualizacion INTEGER NOT NULL,
    protegido BOOLEAN NOT NULL DEFAULT FALSE,
    es_terminal BOOLEAN NOT NULL DEFAULT FALSE,
    activo BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT uq_estado_incidente_codigo
        UNIQUE (codigo),

    CONSTRAINT ck_estado_incidente_codigo
        CHECK (codigo = UPPER(BTRIM(codigo)) AND codigo <> ''),

    CONSTRAINT ck_estado_incidente_orden
        CHECK (orden_visualizacion >= 0)
);

INSERT INTO ESTADO_INCIDENTE
    (codigo, descripcion, orden_visualizacion, protegido, es_terminal)
VALUES
    ('REGISTRADO', 'Incidente registrado', 1, TRUE, FALSE),
    ('EN_GESTION', 'Incidente en gestión', 2, TRUE, FALSE),
    ('PENDIENTE', 'Incidente pendiente', 3, TRUE, FALSE),
    ('RESUELTO', 'Incidente resuelto', 4, TRUE, TRUE);

-- =========================================================
-- 13. TRANSICION_ESTADO_INCIDENTE
-- =========================================================

CREATE TABLE TRANSICION_ESTADO_INCIDENTE (
    id_transicion BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_estado_origen BIGINT NOT NULL,
    id_estado_destino BIGINT NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_transicion_origen
        FOREIGN KEY (id_estado_origen)
        REFERENCES ESTADO_INCIDENTE(id_estado_incidente),

    CONSTRAINT fk_transicion_destino
        FOREIGN KEY (id_estado_destino)
        REFERENCES ESTADO_INCIDENTE(id_estado_incidente),

    CONSTRAINT uq_transicion_origen_destino
        UNIQUE (id_estado_origen, id_estado_destino),

    CONSTRAINT ck_transicion_estados_distintos
        CHECK (id_estado_origen <> id_estado_destino)
);

INSERT INTO TRANSICION_ESTADO_INCIDENTE
    (id_estado_origen, id_estado_destino)
SELECT origen.id_estado_incidente, destino.id_estado_incidente
FROM (
    VALUES
        ('REGISTRADO', 'EN_GESTION'),
        ('EN_GESTION', 'PENDIENTE'),
        ('PENDIENTE', 'EN_GESTION'),
        ('EN_GESTION', 'RESUELTO'),
        ('PENDIENTE', 'RESUELTO')
) AS t(codigo_origen, codigo_destino)
JOIN ESTADO_INCIDENTE origen
    ON origen.codigo = t.codigo_origen
JOIN ESTADO_INCIDENTE destino
    ON destino.codigo = t.codigo_destino;

-- =========================================================
-- 14. UBICACION
-- =========================================================

CREATE TABLE UBICACION (
    id_ubicacion BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT,
    direccion_simulada VARCHAR(250),
    municipio VARCHAR(120),
    provincia VARCHAR(120),
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_creacion TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX uq_ubicacion_nombre_normalizado
ON UBICACION (LOWER(BTRIM(nombre)));

-- =========================================================
-- 15. INCIDENTE
-- =========================================================

CREATE TABLE INCIDENTE (
    id_incidente BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    id_organizacion BIGINT NOT NULL,
    id_tipo_incidente BIGINT NOT NULL,
    id_estado_incidente BIGINT NOT NULL,
    id_ubicacion BIGINT,

    titulo VARCHAR(200) NOT NULL,
    descripcion TEXT NOT NULL,
    fecha_incidente TIMESTAMPTZ NOT NULL,

    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_creacion TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_modificacion TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_incidente_organizacion
        FOREIGN KEY (id_organizacion)
        REFERENCES ORGANIZACION(id_organizacion),

    CONSTRAINT fk_incidente_tipo
        FOREIGN KEY (id_tipo_incidente)
        REFERENCES TIPO_INCIDENTE(id_tipo_incidente),

    CONSTRAINT fk_incidente_estado
        FOREIGN KEY (id_estado_incidente)
        REFERENCES ESTADO_INCIDENTE(id_estado_incidente),

    CONSTRAINT fk_incidente_ubicacion
        FOREIGN KEY (id_ubicacion)
        REFERENCES UBICACION(id_ubicacion)
);

CREATE INDEX idx_incidente_organizacion
ON INCIDENTE (id_organizacion);

CREATE INDEX idx_incidente_estado
ON INCIDENTE (id_estado_incidente);

CREATE INDEX idx_incidente_fecha
ON INCIDENTE (fecha_incidente);

CREATE INDEX idx_incidente_tipo
ON INCIDENTE (id_tipo_incidente);

-- =========================================================
-- 16. VINCULACION_PERSONA_INCIDENTE
-- =========================================================

CREATE TABLE VINCULACION_PERSONA_INCIDENTE (
    id_vinculacion BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    id_persona BIGINT NOT NULL,
    id_incidente BIGINT NOT NULL,

    tipo_vinculacion VARCHAR(40) NOT NULL,
    descripcion TEXT,

    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_creacion TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_modificacion TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_vinculacion_persona
        FOREIGN KEY (id_persona)
        REFERENCES PERSONA(id_persona),

    CONSTRAINT fk_vinculacion_incidente
        FOREIGN KEY (id_incidente)
        REFERENCES INCIDENTE(id_incidente),

    CONSTRAINT ck_vinculacion_tipo
        CHECK (
            tipo_vinculacion IN (
                'VICTIMA',
                'AFECTADO',
                'PERJUDICADO',
                'DENUNCIANTE',
                'TESTIGO',
                'INVESTIGADO',
                'DETENIDO',
                'PRESUNTO_AUTOR',
                'REPRESENTANTE',
                'SOLICITANTE',
                'AGENTE_ACTUANTE',
                'OTRO'
            )
        )
);

-- Evita duplicar una misma vinculación activa,
-- pero permite conservar vinculaciones históricas.
CREATE UNIQUE INDEX uq_vinculacion_activa
ON VINCULACION_PERSONA_INCIDENTE (
    id_persona,
    id_incidente,
    tipo_vinculacion
)
WHERE activo = TRUE;

CREATE INDEX idx_vinculacion_persona
ON VINCULACION_PERSONA_INCIDENTE (id_persona);

CREATE INDEX idx_vinculacion_incidente
ON VINCULACION_PERSONA_INCIDENTE (id_incidente);

-- =========================================================
-- 17. ASIGNACION_INCIDENTE
-- =========================================================

CREATE TABLE ASIGNACION_INCIDENTE (
    id_asignacion BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    id_incidente BIGINT NOT NULL,
    id_usuario BIGINT,
    id_unidad BIGINT,

    fecha_inicio TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_fin TIMESTAMPTZ,

    activo BOOLEAN NOT NULL DEFAULT TRUE,
    observaciones TEXT,

    CONSTRAINT fk_asignacion_incidente
        FOREIGN KEY (id_incidente)
        REFERENCES INCIDENTE(id_incidente),

    CONSTRAINT fk_asignacion_usuario
        FOREIGN KEY (id_usuario)
        REFERENCES USUARIO(id_usuario),

    CONSTRAINT fk_asignacion_unidad
        FOREIGN KEY (id_unidad)
        REFERENCES UNIDAD_ORGANIZATIVA(id_unidad),

    -- Exactamente un destinatario.
    CONSTRAINT ck_asignacion_destinatario
        CHECK (
            (id_usuario IS NOT NULL AND id_unidad IS NULL)
            OR
            (id_usuario IS NULL AND id_unidad IS NOT NULL)
        ),

    CONSTRAINT ck_asignacion_fechas
        CHECK (
            (activo = TRUE AND fecha_fin IS NULL)
            OR
            (
                activo = FALSE
                AND fecha_fin IS NOT NULL
                AND fecha_fin > fecha_inicio
            )
        )
);

-- Una asignación activa por incidente y usuario.
CREATE UNIQUE INDEX uq_asignacion_incidente_usuario_activa
ON ASIGNACION_INCIDENTE (id_incidente, id_usuario)
WHERE activo = TRUE
  AND id_usuario IS NOT NULL;

-- Una asignación activa por incidente y unidad.
CREATE UNIQUE INDEX uq_asignacion_incidente_unidad_activa
ON ASIGNACION_INCIDENTE (id_incidente, id_unidad)
WHERE activo = TRUE
  AND id_unidad IS NOT NULL;

CREATE INDEX idx_asignacion_incidente
ON ASIGNACION_INCIDENTE (id_incidente);

CREATE INDEX idx_asignacion_usuario
ON ASIGNACION_INCIDENTE (id_usuario)
WHERE id_usuario IS NOT NULL;

CREATE INDEX idx_asignacion_unidad
ON ASIGNACION_INCIDENTE (id_unidad)
WHERE id_unidad IS NOT NULL;

-- =========================================================
-- 18. DOCUMENTO_ASOCIADO
-- =========================================================

CREATE TABLE DOCUMENTO_ASOCIADO (
    id_documento BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    id_incidente BIGINT,
    id_persona BIGINT,
    id_antecedente BIGINT,

    nombre VARCHAR(200) NOT NULL,
    tipo_documento VARCHAR(80),
    descripcion TEXT,
    referencia_simulada VARCHAR(500) NOT NULL,

    activo BOOLEAN NOT NULL DEFAULT TRUE,

    fecha_creacion TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_documento_incidente
        FOREIGN KEY (id_incidente)
        REFERENCES INCIDENTE(id_incidente),

    CONSTRAINT fk_documento_persona
        FOREIGN KEY (id_persona)
        REFERENCES PERSONA(id_persona),

    CONSTRAINT fk_documento_antecedente
        FOREIGN KEY (id_antecedente)
        REFERENCES ANTECEDENTE(id_antecedente),

    CONSTRAINT ck_documento_destino
        CHECK (
            num_nonnulls(
                id_incidente,
                id_persona,
                id_antecedente
            ) = 1
        )
);

CREATE INDEX idx_documento_incidente
ON DOCUMENTO_ASOCIADO (id_incidente)
WHERE id_incidente IS NOT NULL;

CREATE INDEX idx_documento_persona
ON DOCUMENTO_ASOCIADO (id_persona)
WHERE id_persona IS NOT NULL;

CREATE INDEX idx_documento_antecedente
ON DOCUMENTO_ASOCIADO (id_antecedente)
WHERE id_antecedente IS NOT NULL;

-- =========================================================
-- 19. AVISO_SEGUIMIENTO
-- =========================================================

CREATE TABLE AVISO_SEGUIMIENTO (
    id_aviso BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    id_incidente BIGINT NOT NULL,
    id_usuario_gestion BIGINT,

    origen VARCHAR(20) NOT NULL,
    clave_deduplicacion VARCHAR(120),

    estado VARCHAR(20) NOT NULL DEFAULT 'PENDIENTE',
    descripcion TEXT,

    fecha_creacion TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_gestion TIMESTAMPTZ,

    activo BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_aviso_incidente
        FOREIGN KEY (id_incidente)
        REFERENCES INCIDENTE(id_incidente),

    CONSTRAINT fk_aviso_usuario
        FOREIGN KEY (id_usuario_gestion)
        REFERENCES USUARIO(id_usuario),

    CONSTRAINT ck_aviso_origen
        CHECK (origen IN ('AUTOMATICO', 'MANUAL')),

    CONSTRAINT ck_aviso_estado
        CHECK (
            estado IN (
                'PENDIENTE',
                'EN_GESTION',
                'GESTIONADO',
                'CANCELADO'
            )
        ),

    CONSTRAINT ck_aviso_origen_deduplicacion
        CHECK (
            (origen = 'AUTOMATICO'
             AND clave_deduplicacion IS NOT NULL
             AND BTRIM(clave_deduplicacion) <> '')
            OR
            (origen = 'MANUAL'
             AND clave_deduplicacion IS NULL)
        ),

    CONSTRAINT ck_aviso_fecha_gestion
        CHECK (
            fecha_gestion IS NULL
            OR fecha_gestion >= fecha_creacion
        ),

    CONSTRAINT ck_aviso_responsable
        CHECK (
            (
                estado = 'PENDIENTE'
                AND id_usuario_gestion IS NULL
                AND fecha_gestion IS NULL
            )
            OR
            (
                estado IN ('EN_GESTION', 'GESTIONADO')
                AND id_usuario_gestion IS NOT NULL
                AND fecha_gestion IS NOT NULL
            )
            OR
            (
                estado = 'CANCELADO'
                AND (
                    (id_usuario_gestion IS NULL
                     AND fecha_gestion IS NULL)
                    OR
                    (id_usuario_gestion IS NOT NULL
                     AND fecha_gestion IS NOT NULL)
                )
            )
        ),

    CONSTRAINT ck_aviso_archivado_estado
        CHECK (
            activo = TRUE
            OR estado IN ('GESTIONADO', 'CANCELADO')
        )
);

CREATE UNIQUE INDEX uq_aviso_clave_deduplicacion
ON AVISO_SEGUIMIENTO (clave_deduplicacion)
WHERE clave_deduplicacion IS NOT NULL;

CREATE INDEX idx_aviso_incidente_estado
ON AVISO_SEGUIMIENTO (id_incidente, estado);

CREATE INDEX idx_aviso_usuario_gestion
ON AVISO_SEGUIMIENTO (id_usuario_gestion)
WHERE id_usuario_gestion IS NOT NULL;

-- =========================================================
-- 20. AUDITORIA
-- =========================================================

CREATE TABLE AUDITORIA (
    id_auditoria BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    id_usuario BIGINT,
    id_organizacion_contexto BIGINT,

    origen VARCHAR(20) NOT NULL,
    entidad VARCHAR(80),
    id_registro BIGINT,

    accion VARCHAR(40) NOT NULL,

    valores_anteriores JSONB,
    valores_nuevos JSONB,

    detalle TEXT,
    fecha_evento TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_auditoria_usuario
        FOREIGN KEY (id_usuario)
        REFERENCES USUARIO(id_usuario),

    CONSTRAINT fk_auditoria_organizacion
        FOREIGN KEY (id_organizacion_contexto)
        REFERENCES ORGANIZACION(id_organizacion),

    CONSTRAINT ck_auditoria_origen
        CHECK (
            (origen = 'USUARIO' AND id_usuario IS NOT NULL)
            OR
            (origen = 'SISTEMA' AND id_usuario IS NULL)
        ),

    CONSTRAINT ck_auditoria_entidad_registro
        CHECK (
            (entidad IS NULL AND id_registro IS NULL)
            OR
            (entidad IS NOT NULL AND id_registro IS NOT NULL)
        ),

    CONSTRAINT ck_auditoria_snapshots_objeto
        CHECK (
            (valores_anteriores IS NULL OR jsonb_typeof(valores_anteriores) = 'object')
            AND
            (valores_nuevos IS NULL OR jsonb_typeof(valores_nuevos) = 'object')
        ),

    CONSTRAINT ck_auditoria_accion
        CHECK (
            accion IN (
                'INSERT',
                'UPDATE',
                'ARCHIVE',
                'RESTORE',
                'ASSIGN',
                'UNASSIGN',
                'STATE_CHANGE',
                'LOGIN',
                'LOGOUT',
                'LOGIN_FAILED',
                'ACCOUNT_LOCK',
                'ACCOUNT_UNLOCK',
                'SESSION_REVOKE',
                'ACCESS_DENIED',
                'EXPORT',
                'TRANSFER',
                'UNIT_CHANGE',
                'PROFILE_CHANGE',
                'PASSWORD_RESET',
                'PASSWORD_CHANGE',
                'SESSION_EXPIRED',
                'DATA_ACCESS',
                'SEARCH'
            )
        )
);

CREATE INDEX idx_auditoria_usuario_fecha
ON AUDITORIA (id_usuario, fecha_evento);

CREATE INDEX idx_auditoria_entidad_registro
ON AUDITORIA (entidad, id_registro);

CREATE INDEX idx_auditoria_fecha
ON AUDITORIA (fecha_evento);

CREATE INDEX idx_auditoria_organizacion_fecha
ON AUDITORIA (id_organizacion_contexto, fecha_evento);


-- =========================================================
-- 21. EJECUCION_PROCESO
-- =========================================================

CREATE TABLE EJECUCION_PROCESO (
    id_ejecucion BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    codigo_proceso VARCHAR(100) NOT NULL,
    identificador_ejecucion VARCHAR(150),

    estado VARCHAR(20) NOT NULL,
    numero_intento INTEGER NOT NULL DEFAULT 1,

    fecha_inicio TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_fin TIMESTAMPTZ,

    resultado JSONB,
    detalle_error TEXT,

    CONSTRAINT ck_ejecucion_estado
        CHECK (
            estado IN (
                'EN_EJECUCION',
                'COMPLETADA',
                'FALLIDA'
            )
        ),

    CONSTRAINT ck_ejecucion_intentos
        CHECK (numero_intento >= 1),

    CONSTRAINT ck_ejecucion_fechas
        CHECK (
            fecha_fin IS NULL
            OR fecha_fin >= fecha_inicio
        ),
    CONSTRAINT ck_ejecucion_estado_fechas
        CHECK (
            (estado = 'EN_EJECUCION' AND fecha_fin IS NULL)
            OR (estado IN ('COMPLETADA', 'FALLIDA') AND fecha_fin IS NOT NULL)
        ),

    CONSTRAINT ck_ejecucion_codigo
        CHECK (BTRIM(codigo_proceso) <> ''),

    CONSTRAINT ck_ejecucion_identificador
        CHECK (
            identificador_ejecucion IS NULL
            OR BTRIM(identificador_ejecucion) <> ''
        ),

    CONSTRAINT ck_ejecucion_error_fallida
        CHECK (
            estado <> 'FALLIDA'
            OR (
                detalle_error IS NOT NULL
                AND BTRIM(detalle_error) <> ''
            )
        )
);

CREATE UNIQUE INDEX uq_ejecucion_idempotencia
ON EJECUCION_PROCESO (codigo_proceso, identificador_ejecucion)
WHERE identificador_ejecucion IS NOT NULL;

CREATE INDEX idx_ejecucion_proceso_fecha
ON EJECUCION_PROCESO (codigo_proceso, fecha_inicio DESC);

CREATE INDEX idx_ejecucion_estado
ON EJECUCION_PROCESO (estado);

-- =========================================================
-- 22. ALERTA_TECNICA
-- =========================================================

CREATE TABLE ALERTA_TECNICA (
    id_alerta BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    id_usuario_responsable BIGINT,
    id_alerta_anterior BIGINT,

    codigo VARCHAR(100) NOT NULL,
    origen VARCHAR(100) NOT NULL,
    recurso VARCHAR(200),

    severidad VARCHAR(20) NOT NULL,
    estado VARCHAR(20) NOT NULL DEFAULT 'NUEVA',

    descripcion TEXT NOT NULL,
    observacion_final TEXT,

    numero_ocurrencias INTEGER NOT NULL DEFAULT 1,

    primera_ocurrencia TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ultima_ocurrencia TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    fecha_resolucion TIMESTAMPTZ,
    fecha_cierre TIMESTAMPTZ,

    CONSTRAINT fk_alerta_responsable
        FOREIGN KEY (id_usuario_responsable)
        REFERENCES USUARIO(id_usuario),

    CONSTRAINT fk_alerta_anterior
        FOREIGN KEY (id_alerta_anterior)
        REFERENCES ALERTA_TECNICA(id_alerta),

    CONSTRAINT ck_alerta_severidad
        CHECK (
            severidad IN (
                'INFO',
                'WARNING',
                'ERROR',
                'CRITICAL'
            )
        ),

    CONSTRAINT ck_alerta_estado
        CHECK (
            estado IN (
                'NUEVA',
                'EN_REVISION',
                'RESUELTA',
                'CERRADA'
            )
        ),

    CONSTRAINT ck_alerta_responsable
        CHECK (
            estado <> 'EN_REVISION'
            OR id_usuario_responsable IS NOT NULL
        ),

    CONSTRAINT ck_alerta_ocurrencias
        CHECK (numero_ocurrencias >= 1),

    CONSTRAINT ck_alerta_texto
        CHECK (
            BTRIM(codigo) <> ''
            AND BTRIM(origen) <> ''
            AND BTRIM(descripcion) <> ''
        ),

    CONSTRAINT ck_alerta_ocurrencia_cronologia
        CHECK (ultima_ocurrencia >= primera_ocurrencia),

    CONSTRAINT ck_alerta_fechas
        CHECK (
            (fecha_resolucion IS NULL OR
             fecha_resolucion >= primera_ocurrencia)
            AND
            (fecha_cierre IS NULL OR
             (
                 fecha_resolucion IS NOT NULL
                 AND fecha_cierre >= fecha_resolucion
             ))
        ),

    CONSTRAINT ck_alerta_estado_fechas
        CHECK (
            (
                estado IN ('NUEVA', 'EN_REVISION')
                AND fecha_resolucion IS NULL
                AND fecha_cierre IS NULL
            )
            OR
            (
                estado = 'RESUELTA'
                AND fecha_resolucion IS NOT NULL
                AND fecha_cierre IS NULL
            )
            OR
            (
                estado = 'CERRADA'
                AND fecha_resolucion IS NOT NULL
                AND fecha_cierre IS NOT NULL
            )
        ),

    CONSTRAINT ck_alerta_observacion_final
        CHECK (
            observacion_final IS NULL
            OR BTRIM(observacion_final) <> ''
        ),

    CONSTRAINT ck_alerta_cierre_observacion
        CHECK (
            estado <> 'CERRADA'
            OR (
                fecha_resolucion IS NOT NULL
                AND fecha_cierre IS NOT NULL
                AND observacion_final IS NOT NULL
                AND BTRIM(observacion_final) <> ''
            )
        )
);

CREATE INDEX idx_alerta_estado_severidad
ON ALERTA_TECNICA (estado, severidad);

CREATE INDEX idx_alerta_fecha
ON ALERTA_TECNICA (primera_ocurrencia DESC);

-- =========================================================
-- 23. ACTUACION_ALERTA
-- =========================================================

CREATE TABLE ACTUACION_ALERTA (
    id_actuacion BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    id_alerta BIGINT NOT NULL,
    id_usuario BIGINT,

    tipo_actuacion VARCHAR(40) NOT NULL,
    descripcion TEXT NOT NULL,

    fecha_actuacion TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_actuacion_alerta
        FOREIGN KEY (id_alerta)
        REFERENCES ALERTA_TECNICA(id_alerta),

    CONSTRAINT fk_actuacion_usuario
        FOREIGN KEY (id_usuario)
        REFERENCES USUARIO(id_usuario),

    CONSTRAINT ck_actuacion_descripcion
        CHECK (BTRIM(descripcion) <> ''),

    CONSTRAINT ck_actuacion_tipo
        CHECK (
            tipo_actuacion IN (
                'CREACION',
                'CAMBIO_ESTADO',
                'ASIGNACION',
                'COMENTARIO',
                'ACCION_CORRECTIVA',
                'VERIFICACION',
                'CIERRE'
            )
        )
);

CREATE INDEX idx_actuacion_alerta_fecha
ON ACTUACION_ALERTA (id_alerta, fecha_actuacion);


-- =========================================================
-- 24. CONFIGURACION_UMBRAL
-- =========================================================

CREATE TABLE CONFIGURACION_UMBRAL (
    id_configuracion BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    codigo VARCHAR(100) NOT NULL,
    version INTEGER NOT NULL,

    valor NUMERIC(15,4) NOT NULL,
    severidad VARCHAR(20) NOT NULL,
    condicion VARCHAR(250) NOT NULL,

    motivo TEXT NOT NULL,

    fecha_efectiva TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    vigente BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT ck_umbral_codigo
        CHECK (codigo = UPPER(BTRIM(codigo)) AND codigo <> ''),
    CONSTRAINT ck_umbral_version
        CHECK (version >= 1),

    CONSTRAINT ck_umbral_valor
        CHECK (valor >= 0),

    CONSTRAINT ck_umbral_severidad
        CHECK (
            severidad IN (
                'INFO',
                'WARNING',
                'ERROR',
                'CRITICAL'
            )
        )
);

CREATE UNIQUE INDEX uq_umbral_codigo_version_normalizado
ON CONFIGURACION_UMBRAL (LOWER(BTRIM(codigo)), version);

CREATE UNIQUE INDEX uq_umbral_vigente
ON CONFIGURACION_UMBRAL (LOWER(BTRIM(codigo)))
WHERE vigente = TRUE;

CREATE INDEX idx_umbral_codigo_fecha
ON CONFIGURACION_UMBRAL (LOWER(BTRIM(codigo)), fecha_efectiva DESC);

CREATE OR REPLACE FUNCTION fn_validar_alta_incidente()
RETURNS TRIGGER AS $$
DECLARE
    v_estado_registrado BIGINT;
    v_organizacion_activa BOOLEAN;
    v_tipo_activo BOOLEAN;
    v_ubicacion_activa BOOLEAN;
BEGIN
    SELECT id_estado_incidente
    INTO v_estado_registrado
    FROM ESTADO_INCIDENTE
    WHERE codigo = 'REGISTRADO'
      AND activo = TRUE;

    IF v_estado_registrado IS NULL THEN
        RAISE EXCEPTION 'No existe un estado REGISTRADO activo.';
    END IF;

    -- El estado inicial lo decide el servidor, nunca el cliente.
    NEW.id_estado_incidente := v_estado_registrado;

    SELECT activo INTO v_organizacion_activa
    FROM ORGANIZACION
    WHERE id_organizacion = NEW.id_organizacion
    FOR SHARE;

    IF COALESCE(v_organizacion_activa, FALSE) = FALSE THEN
        RAISE EXCEPTION
            'La organización del incidente debe estar activa.';
    END IF;

    SELECT activo INTO v_tipo_activo
    FROM TIPO_INCIDENTE
    WHERE id_tipo_incidente = NEW.id_tipo_incidente
    FOR SHARE;

    IF COALESCE(v_tipo_activo, FALSE) = FALSE THEN
        RAISE EXCEPTION
            'El tipo de incidente debe estar activo.';
    END IF;

    IF NEW.id_ubicacion IS NOT NULL THEN
        SELECT activo INTO v_ubicacion_activa
        FROM UBICACION
        WHERE id_ubicacion = NEW.id_ubicacion
        FOR SHARE;

        IF COALESCE(v_ubicacion_activa, FALSE) = FALSE THEN
            RAISE EXCEPTION
                'La ubicación debe estar activa.';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_alta_incidente
BEFORE INSERT ON INCIDENTE
FOR EACH ROW
EXECUTE FUNCTION fn_validar_alta_incidente();

CREATE OR REPLACE FUNCTION fn_validar_cambio_ubicacion_incidente()
RETURNS TRIGGER AS $$
DECLARE
    v_activa BOOLEAN;
BEGIN
    IF NEW.id_ubicacion IS DISTINCT FROM OLD.id_ubicacion
       AND NEW.id_ubicacion IS NOT NULL THEN

        IF NEW.activo = FALSE THEN
            RAISE EXCEPTION
                'No se puede modificar la ubicación de un incidente archivado.';
        END IF;

        SELECT activo INTO v_activa
        FROM UBICACION
        WHERE id_ubicacion = NEW.id_ubicacion
        FOR SHARE;

        IF COALESCE(v_activa, FALSE) = FALSE THEN
            RAISE EXCEPTION
                'La nueva ubicación debe estar activa.';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_cambio_ubicacion_incidente
BEFORE UPDATE OF id_ubicacion ON INCIDENTE
FOR EACH ROW
EXECUTE FUNCTION fn_validar_cambio_ubicacion_incidente();

CREATE OR REPLACE FUNCTION fn_proteger_identidad_asignacion()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.id_incidente IS DISTINCT FROM OLD.id_incidente
       OR NEW.id_usuario IS DISTINCT FROM OLD.id_usuario
       OR NEW.id_unidad IS DISTINCT FROM OLD.id_unidad
       OR NEW.fecha_inicio IS DISTINCT FROM OLD.fecha_inicio THEN

        RAISE EXCEPTION
            'La identidad y fecha de inicio de una asignación son inmutables.';
    END IF;

    IF OLD.activo = FALSE AND NEW.activo = TRUE THEN
        RAISE EXCEPTION
            'Una asignación retirada no se reactiva; debe crearse una nueva.';
    END IF;

    IF OLD.activo = TRUE AND NEW.activo = FALSE THEN
        IF NEW.fecha_fin IS NULL THEN
            RAISE EXCEPTION
                'La retirada de una asignación requiere fecha de finalización.';
        END IF;

        IF NEW.fecha_fin <= OLD.fecha_inicio THEN
            RAISE EXCEPTION
                'La fecha de finalización debe ser posterior al inicio.';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_proteger_identidad_asignacion
BEFORE UPDATE ON ASIGNACION_INCIDENTE
FOR EACH ROW
EXECUTE FUNCTION fn_proteger_identidad_asignacion();

CREATE OR REPLACE FUNCTION fn_proteger_organizacion_incidente()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.id_organizacion IS DISTINCT FROM OLD.id_organizacion THEN
        RAISE EXCEPTION
            'La organización propietaria de un incidente es inmutable.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_proteger_organizacion_incidente
BEFORE UPDATE OF id_organizacion ON INCIDENTE
FOR EACH ROW
EXECUTE FUNCTION fn_proteger_organizacion_incidente();

-- =========================================================
-- PROTECCION DE HISTORIALES TEMPORALES
-- =========================================================

CREATE OR REPLACE FUNCTION fn_proteger_historial_organizativo()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        RAISE EXCEPTION
            'Los historiales organizativos no se pueden eliminar.';
    END IF;

    IF TG_OP = 'UPDATE' THEN

        IF OLD.fecha_fin IS NOT NULL THEN
            RAISE EXCEPTION
                'Un periodo histórico cerrado es inmutable.';
        END IF;

        IF NEW.fecha_inicio IS DISTINCT FROM OLD.fecha_inicio
           OR NEW.id_usuario IS DISTINCT FROM OLD.id_usuario THEN
            RAISE EXCEPTION
                'La identidad y fecha de inicio del historial son inmutables.';
        END IF;

        IF TG_TABLE_NAME = 'historial_pertenencia_organizativa'
           AND NEW.id_organizacion IS DISTINCT FROM OLD.id_organizacion THEN
            RAISE EXCEPTION
                'La organización del historial es inmutable.';
        END IF;

        IF TG_TABLE_NAME = 'historial_unidad_usuario' THEN
            IF NEW.id_historial IS DISTINCT FROM OLD.id_historial
               OR NEW.id_unidad IS DISTINCT FROM OLD.id_unidad THEN
                RAISE EXCEPTION
                    'La pertenencia y unidad del historial son inmutables.';
            END IF;
        END IF;

        IF TG_TABLE_NAME = 'historial_perfil_usuario'
           AND NEW.id_perfil IS DISTINCT FROM OLD.id_perfil THEN
            RAISE EXCEPTION
                'El perfil del historial es inmutable.';
        END IF;

        IF NEW.fecha_fin IS NULL
           OR NEW.fecha_fin <= OLD.fecha_inicio THEN
            RAISE EXCEPTION
                'El cierre requiere una fecha posterior al inicio.';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_proteger_historial_pertenencia
BEFORE UPDATE OR DELETE ON HISTORIAL_PERTENENCIA_ORGANIZATIVA
FOR EACH ROW
EXECUTE FUNCTION fn_proteger_historial_organizativo();

CREATE TRIGGER trg_proteger_historial_unidad
BEFORE UPDATE OR DELETE ON HISTORIAL_UNIDAD_USUARIO
FOR EACH ROW
EXECUTE FUNCTION fn_proteger_historial_organizativo();

CREATE TRIGGER trg_proteger_historial_perfil
BEFORE UPDATE OR DELETE ON HISTORIAL_PERFIL_USUARIO
FOR EACH ROW
EXECUTE FUNCTION fn_proteger_historial_organizativo();

CREATE OR REPLACE FUNCTION fn_validar_alta_historial_abierto()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.fecha_fin IS NOT NULL THEN
        RAISE EXCEPTION
            'Los nuevos periodos históricos deben crearse abiertos.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_alta_historial_pertenencia
BEFORE INSERT ON HISTORIAL_PERTENENCIA_ORGANIZATIVA
FOR EACH ROW
EXECUTE FUNCTION fn_validar_alta_historial_abierto();

CREATE TRIGGER trg_alta_historial_unidad
BEFORE INSERT ON HISTORIAL_UNIDAD_USUARIO
FOR EACH ROW
EXECUTE FUNCTION fn_validar_alta_historial_abierto();

CREATE TRIGGER trg_alta_historial_perfil
BEFORE INSERT ON HISTORIAL_PERFIL_USUARIO
FOR EACH ROW
EXECUTE FUNCTION fn_validar_alta_historial_abierto();

CREATE OR REPLACE FUNCTION fn_validar_historial_unidad()
RETURNS TRIGGER AS $$
DECLARE
    v_org_historial BIGINT;
    v_inicio_historial TIMESTAMPTZ;
    v_fin_historial TIMESTAMPTZ;
    v_org_unidad BIGINT;
    v_unidad_activa BOOLEAN;
BEGIN
    SELECT id_organizacion, fecha_inicio, fecha_fin
    INTO v_org_historial, v_inicio_historial, v_fin_historial
    FROM HISTORIAL_PERTENENCIA_ORGANIZATIVA
    WHERE id_historial = NEW.id_historial
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION
            'No existe el periodo de pertenencia organizativa.';
    END IF;

    SELECT id_organizacion, activo
    INTO v_org_unidad, v_unidad_activa
    FROM UNIDAD_ORGANIZATIVA
    WHERE id_unidad = NEW.id_unidad
    FOR UPDATE;

    IF NOT FOUND
       OR v_unidad_activa = FALSE
       OR v_org_unidad <> v_org_historial THEN
        RAISE EXCEPTION
            'La unidad debe estar activa y pertenecer a la organización del historial.';
    END IF;

    IF NEW.fecha_inicio < v_inicio_historial
       OR (
           v_fin_historial IS NOT NULL
           AND (
               NEW.fecha_fin IS NULL
               OR NEW.fecha_fin > v_fin_historial
           )
       ) THEN
        RAISE EXCEPTION
            'El periodo de unidad debe estar comprendido en el periodo organizativo.';
    END IF;

    IF v_fin_historial IS NULL
       AND NEW.fecha_fin IS NOT NULL THEN
        NULL;
    ELSIF v_fin_historial IS NOT NULL
       AND NEW.fecha_fin IS NULL THEN
        RAISE EXCEPTION
            'El periodo de unidad no puede superar el periodo organizativo.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_historial_unidad
BEFORE INSERT OR UPDATE ON HISTORIAL_UNIDAD_USUARIO
FOR EACH ROW
EXECUTE FUNCTION fn_validar_historial_unidad();

CREATE OR REPLACE FUNCTION fn_validar_alta_perfil_usuario()
RETURNS TRIGGER AS $$
DECLARE
    v_codigo VARCHAR(50);
    v_pertenencia BOOLEAN;
    v_unidad BOOLEAN;
BEGIN
    IF NEW.fecha_fin IS NOT NULL THEN
        RAISE EXCEPTION
            'Los perfiles deben crearse con un periodo abierto.';
    END IF;

    SELECT codigo, activo
    INTO v_codigo, v_pertenencia
    FROM PERFIL
    WHERE id_perfil = NEW.id_perfil
    FOR UPDATE;

    IF NOT FOUND OR v_pertenencia = FALSE THEN
        RAISE EXCEPTION
            'El perfil debe existir y estar activo.';
    END IF;

    IF v_codigo IN ('AGENTE', 'SUPERVISOR') THEN

        SELECT EXISTS (
            SELECT 1
            FROM HISTORIAL_PERTENENCIA_ORGANIZATIVA h
            WHERE h.id_usuario = NEW.id_usuario
              AND h.fecha_inicio <= NEW.fecha_inicio
              AND (
                  h.fecha_fin IS NULL
                  OR NEW.fecha_inicio < h.fecha_fin
              )
        )
        INTO v_pertenencia;

        IF NOT v_pertenencia THEN
            RAISE EXCEPTION
                'El perfil requiere pertenencia organizativa vigente.';
        END IF;

        SELECT EXISTS (
            SELECT 1
            FROM HISTORIAL_UNIDAD_USUARIO hu
            JOIN HISTORIAL_PERTENENCIA_ORGANIZATIVA hp
              ON hp.id_historial = hu.id_historial
            WHERE hp.id_usuario = NEW.id_usuario
              AND hu.fecha_inicio <= NEW.fecha_inicio
              AND (
                  hu.fecha_fin IS NULL
                  OR NEW.fecha_inicio < hu.fecha_fin
              )
              AND hp.fecha_inicio <= NEW.fecha_inicio
              AND (
                  hp.fecha_fin IS NULL
                  OR NEW.fecha_inicio < hp.fecha_fin
              )
        )
        INTO v_unidad;

        IF NOT v_unidad THEN
            RAISE EXCEPTION
                'El perfil requiere adscripción a una unidad vigente.';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_alta_perfil_usuario
BEFORE INSERT ON HISTORIAL_PERFIL_USUARIO
FOR EACH ROW
EXECUTE FUNCTION fn_validar_alta_perfil_usuario();

CREATE OR REPLACE FUNCTION fn_proteger_archivado_persona()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.activo = FALSE AND NEW.activo = TRUE THEN
        IF NEW.dni IS DISTINCT FROM OLD.dni
           OR NEW.nombre IS DISTINCT FROM OLD.nombre
           OR NEW.apellidos IS DISTINCT FROM OLD.apellidos
           OR NEW.fecha_nacimiento IS DISTINCT FROM OLD.fecha_nacimiento
           OR NEW.telefono IS DISTINCT FROM OLD.telefono
           OR NEW.email IS DISTINCT FROM OLD.email
           OR NEW.domicilio IS DISTINCT FROM OLD.domicilio
           OR NEW.observaciones IS DISTINCT FROM OLD.observaciones
           OR NEW.fecha_creacion IS DISTINCT FROM OLD.fecha_creacion THEN
            RAISE EXCEPTION
                'La reactivación de una persona no puede alterar sus datos.';
        END IF;

        RETURN NEW;
    END IF;

    IF OLD.activo = FALSE AND NEW IS DISTINCT FROM OLD THEN
        RAISE EXCEPTION
            'Una persona archivada es inmutable.';
    END IF;

    IF OLD.activo = TRUE AND NEW.activo = FALSE THEN
        IF NEW.dni IS DISTINCT FROM OLD.dni
           OR NEW.nombre IS DISTINCT FROM OLD.nombre
           OR NEW.apellidos IS DISTINCT FROM OLD.apellidos
           OR NEW.fecha_nacimiento IS DISTINCT FROM OLD.fecha_nacimiento
           OR NEW.telefono IS DISTINCT FROM OLD.telefono
           OR NEW.email IS DISTINCT FROM OLD.email
           OR NEW.domicilio IS DISTINCT FROM OLD.domicilio
           OR NEW.observaciones IS DISTINCT FROM OLD.observaciones
           OR NEW.fecha_creacion IS DISTINCT FROM OLD.fecha_creacion THEN
            RAISE EXCEPTION
                'El archivo de una persona no puede combinarse con cambios en sus datos.';
        END IF;

        IF EXISTS (
            SELECT 1
            FROM ANTECEDENTE a
            WHERE a.id_persona = OLD.id_persona
              AND a.activo = TRUE
              AND a.estado = 'PENDIENTE'
        ) THEN
            RAISE EXCEPTION
                'No se puede archivar una persona con antecedentes pendientes.';
        END IF;

        IF EXISTS (
            SELECT 1
            FROM VINCULACION_PERSONA_INCIDENTE v
            JOIN INCIDENTE i
              ON i.id_incidente = v.id_incidente
            JOIN ESTADO_INCIDENTE e
              ON e.id_estado_incidente = i.id_estado_incidente
            WHERE v.id_persona = OLD.id_persona
              AND v.activo = TRUE
              AND i.activo = TRUE
              AND e.es_terminal = FALSE
        ) THEN
            RAISE EXCEPTION
                'La persona mantiene vinculaciones con incidentes no resueltos.';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_proteger_archivado_persona
BEFORE UPDATE ON PERSONA
FOR EACH ROW
EXECUTE FUNCTION fn_proteger_archivado_persona();

CREATE OR REPLACE FUNCTION fn_validar_estado_antecedente()
RETURNS TRIGGER AS $$
DECLARE
    v_activo BOOLEAN;
BEGIN
    IF TG_OP = 'UPDATE'
       AND OLD.activo = TRUE
       AND NEW.activo = FALSE
       AND OLD.estado = 'PENDIENTE' THEN
        RAISE EXCEPTION
            'No se puede archivar un antecedente pendiente.';
    END IF;

    IF (
        TG_OP = 'INSERT' AND NEW.activo = TRUE
    ) OR (
        TG_OP = 'UPDATE'
        AND OLD.activo = FALSE
        AND NEW.activo = TRUE
    ) THEN

        SELECT activo INTO v_activo
        FROM PERSONA
        WHERE id_persona = NEW.id_persona
        FOR UPDATE;

        IF COALESCE(v_activo, FALSE) = FALSE THEN
            RAISE EXCEPTION
                'La persona debe estar activa.';
        END IF;

        SELECT activo INTO v_activo
        FROM TIPO_ANTECEDENTE
        WHERE id_tipo_antecedente = NEW.id_tipo_antecedente
        FOR UPDATE;

        IF COALESCE(v_activo, FALSE) = FALSE THEN
            RAISE EXCEPTION
                'El tipo de antecedente debe estar activo.';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_estado_antecedente
BEFORE INSERT OR UPDATE OF activo ON ANTECEDENTE
FOR EACH ROW
EXECUTE FUNCTION fn_validar_estado_antecedente();

CREATE OR REPLACE FUNCTION fn_proteger_archivado_incidente()
RETURNS TRIGGER AS $$
DECLARE
    v_terminal BOOLEAN;
    v_activo BOOLEAN;
BEGIN
    IF OLD.activo = TRUE AND NEW.activo = FALSE THEN

        IF EXISTS (
            SELECT 1
            FROM AVISO_SEGUIMIENTO a
            WHERE a.id_incidente = OLD.id_incidente
              AND a.activo = TRUE
              AND a.estado IN ('PENDIENTE', 'EN_GESTION')
        ) THEN
            RAISE EXCEPTION
                'El incidente tiene avisos operativos pendientes.';
        END IF;

        IF EXISTS (
            SELECT 1
            FROM ASIGNACION_INCIDENTE a
            WHERE a.id_incidente = OLD.id_incidente
              AND a.activo = TRUE
        ) THEN
            RAISE EXCEPTION
                'El incidente tiene asignaciones activas.';
        END IF;

    ELSIF OLD.activo = FALSE AND NEW.activo = TRUE THEN

        SELECT es_terminal INTO v_terminal
        FROM ESTADO_INCIDENTE
        WHERE id_estado_incidente = NEW.id_estado_incidente;

        IF COALESCE(v_terminal, TRUE) THEN
            RAISE EXCEPTION
                'No se puede reactivar un incidente con estado terminal.';
        END IF;

        SELECT activo INTO v_activo
        FROM ORGANIZACION
        WHERE id_organizacion = NEW.id_organizacion
        FOR UPDATE;

        IF COALESCE(v_activo, FALSE) = FALSE THEN
            RAISE EXCEPTION
                'La organización debe estar activa.';
        END IF;

        SELECT activo INTO v_activo
        FROM TIPO_INCIDENTE
        WHERE id_tipo_incidente = NEW.id_tipo_incidente
        FOR UPDATE;

        IF COALESCE(v_activo, FALSE) = FALSE THEN
            RAISE EXCEPTION
                'El tipo de incidente debe estar activo.';
        END IF;

        IF NEW.id_ubicacion IS NOT NULL THEN
            SELECT activo INTO v_activo
            FROM UBICACION
            WHERE id_ubicacion = NEW.id_ubicacion
            FOR UPDATE;

            IF COALESCE(v_activo, FALSE) = FALSE THEN
                RAISE EXCEPTION
                    'La ubicación debe estar activa.';
            END IF;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_proteger_archivado_incidente
BEFORE UPDATE OF activo ON INCIDENTE
FOR EACH ROW
EXECUTE FUNCTION fn_proteger_archivado_incidente();

CREATE OR REPLACE FUNCTION fn_proteger_tipo_incidente()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.activo = TRUE AND NEW.activo = FALSE
       AND EXISTS (
           SELECT 1
           FROM INCIDENTE
           WHERE id_tipo_incidente = OLD.id_tipo_incidente
             AND activo = TRUE
       ) THEN
        RAISE EXCEPTION
            'El tipo está siendo utilizado por incidentes activos.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_proteger_tipo_incidente
BEFORE UPDATE OF activo ON TIPO_INCIDENTE
FOR EACH ROW
EXECUTE FUNCTION fn_proteger_tipo_incidente();


CREATE OR REPLACE FUNCTION fn_proteger_tipo_antecedente()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.activo = TRUE AND NEW.activo = FALSE
       AND EXISTS (
           SELECT 1
           FROM ANTECEDENTE
           WHERE id_tipo_antecedente = OLD.id_tipo_antecedente
             AND activo = TRUE
       ) THEN
        RAISE EXCEPTION
            'El tipo está siendo utilizado por antecedentes activos.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_proteger_tipo_antecedente
BEFORE UPDATE OF activo ON TIPO_ANTECEDENTE
FOR EACH ROW
EXECUTE FUNCTION fn_proteger_tipo_antecedente();

-- =========================================================
-- PROTECCION DE AUDITORIA Y ACTUACIONES
-- =========================================================

CREATE OR REPLACE FUNCTION fn_proteger_registro_inmutable()
RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION
        'Este registro es inmutable y no puede modificarse ni eliminarse.';
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_proteger_auditoria
BEFORE UPDATE OR DELETE ON AUDITORIA
FOR EACH ROW
EXECUTE FUNCTION fn_proteger_registro_inmutable();

CREATE TRIGGER trg_proteger_actuacion_alerta
BEFORE UPDATE OR DELETE ON ACTUACION_ALERTA
FOR EACH ROW
EXECUTE FUNCTION fn_proteger_registro_inmutable();

CREATE OR REPLACE FUNCTION fn_validar_aviso_seguimiento()
RETURNS TRIGGER AS $$
DECLARE
    v_activo BOOLEAN;
BEGIN
    IF TG_OP = 'DELETE' THEN
        RAISE EXCEPTION
            'Los avisos de seguimiento se archivan; no se eliminan físicamente.';
    END IF;

    -- ALTA: los avisos nacen activos, pendientes y sin responsable.
    IF TG_OP = 'INSERT' THEN
        IF NEW.estado <> 'PENDIENTE'
           OR NEW.id_usuario_gestion IS NOT NULL
           OR NEW.fecha_gestion IS NOT NULL
           OR NEW.activo IS DISTINCT FROM TRUE THEN
            RAISE EXCEPTION
                'Un aviso nuevo debe comenzar activo, PENDIENTE y sin responsable.';
        END IF;

        SELECT activo
        INTO v_activo
        FROM INCIDENTE
        WHERE id_incidente = NEW.id_incidente
        FOR UPDATE;

        IF NOT FOUND OR NOT v_activo THEN
            RAISE EXCEPTION
                'El aviso requiere un incidente activo.';
        END IF;

        RETURN NEW;
    END IF;

    -- IDENTIDAD INMUTABLE.
    IF NEW.id_incidente IS DISTINCT FROM OLD.id_incidente
      OR NEW.origen IS DISTINCT FROM OLD.origen
      OR NEW.clave_deduplicacion IS DISTINCT FROM OLD.clave_deduplicacion
      OR NEW.fecha_creacion IS DISTINCT FROM OLD.fecha_creacion THEN
        RAISE EXCEPTION
            'La identidad del aviso es inmutable.';
    END IF;

    -- AVISO ARCHIVADO: solo se permite reactivarlo
    -- conservando todos sus datos.
    IF OLD.activo = FALSE THEN
        IF NEW.activo = FALSE THEN
            IF NEW IS DISTINCT FROM OLD THEN
                RAISE EXCEPTION
                    'Un aviso archivado es inmutable.';
            END IF;
            RETURN NEW;
        END IF;

        IF OLD.estado NOT IN ('GESTIONADO', 'CANCELADO')
           OR NEW.estado IS DISTINCT FROM OLD.estado
           OR NEW.id_usuario_gestion IS DISTINCT FROM OLD.id_usuario_gestion
           OR NEW.fecha_gestion IS DISTINCT FROM OLD.fecha_gestion
           OR NEW.descripcion IS DISTINCT FROM OLD.descripcion
           OR NEW.fecha_creacion IS DISTINCT FROM OLD.fecha_creacion
           OR NEW.id_incidente IS DISTINCT FROM OLD.id_incidente
           OR NEW.origen IS DISTINCT FROM OLD.origen
           OR NEW.clave_deduplicacion IS DISTINCT FROM OLD.clave_deduplicacion THEN
            RAISE EXCEPTION
                'La reactivación solo permite cambiar activo y conservar el aviso terminal.';
        END IF;

        SELECT activo
        INTO v_activo
        FROM INCIDENTE
        WHERE id_incidente = NEW.id_incidente
        FOR UPDATE;

        IF NOT FOUND OR NOT v_activo THEN
            RAISE EXCEPTION
                'No se puede reactivar un aviso cuyo incidente está archivado.';
        END IF;

        RETURN NEW;
    END IF;

    -- ARCHIVADO: solo desde un estado terminal
    -- y sin modificar simultáneamente otros datos.
    IF OLD.activo = TRUE AND NEW.activo = FALSE THEN
        IF OLD.estado NOT IN ('GESTIONADO', 'CANCELADO')
           OR NEW.estado IS DISTINCT FROM OLD.estado
           OR NEW.id_usuario_gestion IS DISTINCT FROM OLD.id_usuario_gestion
           OR NEW.fecha_gestion IS DISTINCT FROM OLD.fecha_gestion
           OR NEW.descripcion IS DISTINCT FROM OLD.descripcion THEN
            RAISE EXCEPTION
                'Solo se pueden archivar avisos terminales sin modificar sus datos.';
        END IF;

        RETURN NEW;
    END IF;

    -- TRANSICIONES DE ESTADO.
    IF NEW.estado IS DISTINCT FROM OLD.estado THEN
        IF NOT (
            (OLD.estado = 'PENDIENTE'
                AND NEW.estado IN ('EN_GESTION', 'CANCELADO'))
            OR
            (OLD.estado = 'EN_GESTION'
                AND NEW.estado IN ('GESTIONADO', 'CANCELADO'))
        ) THEN
            RAISE EXCEPTION
                'Transición de aviso no permitida.';
        END IF;

        IF NEW.estado = 'EN_GESTION' THEN
            SELECT activo
            INTO v_activo
            FROM USUARIO
            WHERE id_usuario = NEW.id_usuario_gestion
            FOR UPDATE;

            IF NOT FOUND OR NOT v_activo THEN
                RAISE EXCEPTION
                    'El responsable debe ser un usuario activo.';
            END IF;

            NEW.fecha_gestion := clock_timestamp();

        ELSIF OLD.estado = 'PENDIENTE'
              AND NEW.estado = 'CANCELADO' THEN
            IF NEW.id_usuario_gestion IS NOT NULL
               OR NEW.fecha_gestion IS NOT NULL THEN
                RAISE EXCEPTION
                    'La cancelación desde PENDIENTE no lleva responsable.';
            END IF;

        ELSIF OLD.estado = 'EN_GESTION' THEN
            IF NEW.id_usuario_gestion IS DISTINCT FROM OLD.id_usuario_gestion
               OR NEW.fecha_gestion IS DISTINCT FROM OLD.fecha_gestion THEN
                RAISE EXCEPTION
                    'El responsable y fecha de gestión son inmutables.';
            END IF;
        END IF;

    ELSE
        IF NEW.id_usuario_gestion IS DISTINCT FROM OLD.id_usuario_gestion
           OR NEW.fecha_gestion IS DISTINCT FROM OLD.fecha_gestion THEN
            RAISE EXCEPTION
                'El responsable solo se establece al iniciar la gestión.';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_aviso_seguimiento
BEFORE INSERT OR UPDATE OR DELETE ON AVISO_SEGUIMIENTO
FOR EACH ROW
EXECUTE FUNCTION fn_validar_aviso_seguimiento();

-- =========================================================
-- DEDUPLICACION DE ALERTAS ABIERTAS
-- =========================================================

CREATE UNIQUE INDEX uq_alerta_abierta_deduplicacion
ON ALERTA_TECNICA (
    codigo,
    origen,
    COALESCE(recurso, '')
)
WHERE estado IN ('NUEVA', 'EN_REVISION');

CREATE OR REPLACE FUNCTION fn_validar_alerta_tecnica()
RETURNS TRIGGER AS $$
DECLARE
    v_usuario_activo BOOLEAN;
BEGIN
    -- PROHIBIR ELIMINACIÓN FÍSICA.
    IF TG_OP = 'DELETE' THEN
        RAISE EXCEPTION
            'Las alertas técnicas se conservan para garantizar la trazabilidad.';
    END IF;

    -- ALTA.
    IF TG_OP = 'INSERT' THEN
        IF NEW.estado <> 'NUEVA'
           OR NEW.fecha_resolucion IS NOT NULL
           OR NEW.fecha_cierre IS NOT NULL THEN
            RAISE EXCEPTION
                'Una alerta nueva debe comenzar NUEVA y sin fechas de resolución/cierre.';
        END IF;

        IF NEW.id_usuario_responsable IS NOT NULL THEN
            SELECT activo
            INTO v_usuario_activo
            FROM USUARIO
            WHERE id_usuario = NEW.id_usuario_responsable
            FOR UPDATE;

            IF NOT FOUND OR NOT v_usuario_activo THEN
                RAISE EXCEPTION
                    'El responsable inicial de la alerta debe estar activo.';
            END IF;
        END IF;

        RETURN NEW;
    END IF;

    -- IDENTIDAD INMUTABLE.
    IF NEW.codigo IS DISTINCT FROM OLD.codigo
       OR NEW.origen IS DISTINCT FROM OLD.origen
       OR NEW.recurso IS DISTINCT FROM OLD.recurso
       OR NEW.id_alerta_anterior IS DISTINCT FROM OLD.id_alerta_anterior
       OR NEW.primera_ocurrencia IS DISTINCT FROM OLD.primera_ocurrencia THEN
        RAISE EXCEPTION
            'La identidad de una alerta es inmutable.';
    END IF;

    -- UNA ALERTA CERRADA ES INMUTABLE.
    IF OLD.estado = 'CERRADA' AND NEW IS DISTINCT FROM OLD THEN
        RAISE EXCEPTION
            'Una alerta cerrada es inmutable.';
    END IF;

    -- LA OBSERVACIÓN FINAL SOLO SE INTRODUCE AL CERRAR.
    IF NEW.observacion_final IS DISTINCT FROM OLD.observacion_final
       AND NOT (OLD.estado = 'RESUELTA' AND NEW.estado = 'CERRADA') THEN
        RAISE EXCEPTION
            'La observación final solo puede establecerse al cerrar la alerta.';
    END IF;

    -- UNA ALERTA RESUELTA SOLO ADMITE EL CIERRE FORMAL.
    IF OLD.estado = 'RESUELTA' AND (
        NEW.id_usuario_responsable IS DISTINCT FROM OLD.id_usuario_responsable
        OR NEW.id_alerta_anterior IS DISTINCT FROM OLD.id_alerta_anterior
        OR NEW.codigo IS DISTINCT FROM OLD.codigo
        OR NEW.origen IS DISTINCT FROM OLD.origen
        OR NEW.recurso IS DISTINCT FROM OLD.recurso
        OR NEW.severidad IS DISTINCT FROM OLD.severidad
        OR NEW.descripcion IS DISTINCT FROM OLD.descripcion
        OR NEW.numero_ocurrencias IS DISTINCT FROM OLD.numero_ocurrencias
        OR NEW.primera_ocurrencia IS DISTINCT FROM OLD.primera_ocurrencia
        OR NEW.ultima_ocurrencia IS DISTINCT FROM OLD.ultima_ocurrencia
        OR NEW.fecha_resolucion IS DISTINCT FROM OLD.fecha_resolucion
    ) THEN
        RAISE EXCEPTION
            'Una alerta resuelta solo permite registrar su cierre y observación final.';
    END IF;

    -- CONTADOR Y ÚLTIMA OCURRENCIA NO PUEDEN RETROCEDER.
    IF NEW.numero_ocurrencias < OLD.numero_ocurrencias
       OR NEW.ultima_ocurrencia < OLD.ultima_ocurrencia THEN
        RAISE EXCEPTION
            'El contador y la última ocurrencia no pueden retroceder.';
    END IF;

    -- RESPONSABLE: NO SE PUEDE SUSTITUIR NI RETIRAR.
    IF OLD.id_usuario_responsable IS NOT NULL
       AND NEW.id_usuario_responsable IS DISTINCT FROM OLD.id_usuario_responsable THEN
        RAISE EXCEPTION
            'El responsable de una alerta no se puede sustituir ni retirar.';
    END IF;

    IF NEW.id_usuario_responsable IS NOT NULL
       AND NEW.id_usuario_responsable IS DISTINCT FROM OLD.id_usuario_responsable THEN

        SELECT activo
        INTO v_usuario_activo
        FROM USUARIO
        WHERE id_usuario = NEW.id_usuario_responsable
        FOR UPDATE;

        IF NOT FOUND OR NOT v_usuario_activo THEN
            RAISE EXCEPTION
                'El responsable de la alerta debe estar activo.';
        END IF;
    END IF;

    -- FECHA DE RESOLUCIÓN: SOLO SE ESTABLECE UNA VEZ.
    IF OLD.fecha_resolucion IS NOT NULL
       AND NEW.fecha_resolucion IS DISTINCT FROM OLD.fecha_resolucion THEN
        RAISE EXCEPTION
            'La fecha de resolución es inmutable una vez establecida.';
    END IF;

    IF OLD.fecha_resolucion IS NULL
       AND NEW.fecha_resolucion IS NOT NULL
       AND NOT (OLD.estado IS DISTINCT FROM NEW.estado
                AND NEW.estado = 'RESUELTA') THEN
        RAISE EXCEPTION
            'La fecha de resolución solo se establece al resolver la alerta.';
    END IF;

    -- FECHA DE CIERRE: SOLO LA ESTABLECE EL TRIGGER.
    IF NEW.fecha_cierre IS DISTINCT FROM OLD.fecha_cierre
       AND NOT (OLD.estado IS DISTINCT FROM NEW.estado
                AND NEW.estado = 'CERRADA') THEN
        RAISE EXCEPTION
            'La fecha de cierre solo se establece al cerrar la alerta.';
    END IF;

    -- TRANSICIONES DE ESTADO.
    IF NEW.estado IS DISTINCT FROM OLD.estado THEN

        IF NOT (
            (OLD.estado = 'NUEVA'
                AND NEW.estado IN ('EN_REVISION', 'RESUELTA'))
            OR
            (OLD.estado = 'EN_REVISION'
                AND NEW.estado = 'RESUELTA')
            OR
            (OLD.estado = 'RESUELTA'
                AND NEW.estado = 'CERRADA')
        ) THEN
            RAISE EXCEPTION
                'Transición de alerta no permitida.';
        END IF;

        IF NEW.estado = 'EN_REVISION'
           AND NEW.id_usuario_responsable IS NULL THEN
            RAISE EXCEPTION
                'Una alerta en revisión requiere responsable.';
        END IF;

        -- RESOLUCIÓN: EXIGE ACCIÓN CORRECTIVA Y VERIFICACIÓN.
        IF NEW.estado = 'RESUELTA' THEN

            IF NOT EXISTS (
                SELECT 1
                FROM ACTUACION_ALERTA
                WHERE id_alerta = OLD.id_alerta
                  AND tipo_actuacion = 'ACCION_CORRECTIVA'
            ) OR NOT EXISTS (
                SELECT 1
                FROM ACTUACION_ALERTA
                WHERE id_alerta = OLD.id_alerta
                  AND tipo_actuacion = 'VERIFICACION'
            ) THEN
                RAISE EXCEPTION
                    'Para resolver se requiere acción correctiva y verificación registradas.';
            END IF;

            NEW.fecha_resolucion := clock_timestamp();
        END IF;

        -- CIERRE: REQUIERE RESOLUCIÓN PREVIA Y OBSERVACIÓN FINAL.
        IF NEW.estado = 'CERRADA' THEN

            IF OLD.fecha_resolucion IS NULL
               OR NEW.observacion_final IS NULL
               OR BTRIM(NEW.observacion_final) = '' THEN
                RAISE EXCEPTION
                    'El cierre requiere resolución previa y observación final.';
            END IF;

            NEW.fecha_cierre := clock_timestamp();
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_alerta_tecnica
BEFORE INSERT OR DELETE OR UPDATE ON ALERTA_TECNICA
FOR EACH ROW
EXECUTE FUNCTION fn_validar_alerta_tecnica();

CREATE OR REPLACE FUNCTION fn_proteger_version_umbral()
RETURNS TRIGGER AS $$
DECLARE
    v_max_version INTEGER;
BEGIN
    PERFORM pg_advisory_xact_lock(
        hashtextextended(LOWER(BTRIM(
            CASE
                WHEN TG_OP = 'DELETE' THEN OLD.codigo
                ELSE NEW.codigo
            END
        )), 0)
    );

    IF TG_OP = 'DELETE' THEN
        RAISE EXCEPTION
            'Las versiones de umbrales no se pueden eliminar.';
    END IF;

    IF TG_OP = 'UPDATE' THEN

        IF NEW.codigo IS DISTINCT FROM OLD.codigo
           OR NEW.version IS DISTINCT FROM OLD.version
           OR NEW.valor IS DISTINCT FROM OLD.valor
           OR NEW.severidad IS DISTINCT FROM OLD.severidad
           OR NEW.condicion IS DISTINCT FROM OLD.condicion
           OR NEW.fecha_efectiva IS DISTINCT FROM OLD.fecha_efectiva
           OR NEW.motivo IS DISTINCT FROM OLD.motivo THEN
            RAISE EXCEPTION
                'El contenido de una versión de umbral es inmutable.';
        END IF;

        IF OLD.vigente = FALSE AND NEW.vigente = TRUE THEN
            RAISE EXCEPTION
                'No se puede reactivar una versión histórica.';
        END IF;

        IF OLD.vigente = TRUE AND NEW.vigente = FALSE THEN
            RETURN NEW;
        END IF;

    ELSIF TG_OP = 'INSERT' THEN

        SELECT COALESCE(MAX(version), 0)
        INTO v_max_version
        FROM CONFIGURACION_UMBRAL
        WHERE LOWER(BTRIM(codigo)) = LOWER(BTRIM(NEW.codigo));

        IF NEW.version <> v_max_version + 1 THEN
            RAISE EXCEPTION
                'La nueva versión debe ser consecutiva.';
        END IF;

        IF NEW.vigente = FALSE THEN
            RAISE EXCEPTION
                'Una versión nueva debe crearse como vigente.';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_proteger_version_umbral
BEFORE INSERT OR UPDATE OR DELETE ON CONFIGURACION_UMBRAL
FOR EACH ROW
EXECUTE FUNCTION fn_proteger_version_umbral();

-- =====================================================================
-- BLOQUE 8: CONSOLIDACION Y CORRECCIONES DE INTEGRIDAD
-- Este bloque sustituye funciones defectuosas y completa reglas faltantes.
-- La autorización por rol/ámbito sigue correspondiendo al backend.
-- =====================================================================

-- 8.1 Historiales: función corregida sin acceder a columnas inexistentes.
CREATE OR REPLACE FUNCTION fn_proteger_historial_organizativo()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        RAISE EXCEPTION 'Los historiales organizativos no se pueden eliminar.';
    END IF;

    IF OLD.fecha_fin IS NOT NULL THEN
        RAISE EXCEPTION 'Un periodo histórico cerrado es inmutable.';
    END IF;

    IF NEW.fecha_inicio IS DISTINCT FROM OLD.fecha_inicio THEN
        RAISE EXCEPTION 'La fecha de inicio del historial es inmutable.';
    END IF;

    IF TG_TABLE_NAME = 'historial_pertenencia_organizativa' THEN
        IF NEW.id_usuario IS DISTINCT FROM OLD.id_usuario
           OR NEW.id_organizacion IS DISTINCT FROM OLD.id_organizacion THEN
            RAISE EXCEPTION 'La identidad del periodo organizativo es inmutable.';
        END IF;
    ELSIF TG_TABLE_NAME = 'historial_unidad_usuario' THEN
        IF NEW.id_historial IS DISTINCT FROM OLD.id_historial
           OR NEW.id_unidad IS DISTINCT FROM OLD.id_unidad THEN
            RAISE EXCEPTION 'La pertenencia y unidad del historial son inmutables.';
        END IF;
    ELSIF TG_TABLE_NAME = 'historial_perfil_usuario' THEN
        IF NEW.id_usuario IS DISTINCT FROM OLD.id_usuario
           OR NEW.id_perfil IS DISTINCT FROM OLD.id_perfil THEN
            RAISE EXCEPTION 'El usuario y perfil del historial son inmutables.';
        END IF;
    END IF;

    IF NEW.fecha_fin IS NULL OR NEW.fecha_fin <= OLD.fecha_inicio THEN
        RAISE EXCEPTION 'El cierre requiere una fecha posterior al inicio.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Cerrar una pertenencia exige haber cerrado antes sus adscripciones a unidad.
CREATE OR REPLACE FUNCTION fn_validar_cierre_pertenencia()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.fecha_fin IS NULL AND NEW.fecha_fin IS NOT NULL THEN
        IF EXISTS (
            SELECT 1
            FROM HISTORIAL_UNIDAD_USUARIO hu
            WHERE hu.id_historial = OLD.id_historial
              AND (hu.fecha_fin IS NULL OR hu.fecha_fin > NEW.fecha_fin)
        ) THEN
            RAISE EXCEPTION
                'Debe cerrarse la adscripción a unidad antes de cerrar la pertenencia organizativa.';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_cierre_pertenencia
BEFORE UPDATE OF fecha_fin ON HISTORIAL_PERTENENCIA_ORGANIZATIVA
FOR EACH ROW EXECUTE FUNCTION fn_validar_cierre_pertenencia();

-- Altas de pertenencia: usuario y organización activos.
CREATE OR REPLACE FUNCTION fn_validar_alta_pertenencia()
RETURNS TRIGGER AS $$
DECLARE
    v_activo BOOLEAN;
BEGIN
    SELECT activo INTO v_activo
    FROM USUARIO WHERE id_usuario = NEW.id_usuario FOR UPDATE;
    IF NOT FOUND OR NOT v_activo THEN
        RAISE EXCEPTION 'El usuario debe existir y estar activo.';
    END IF;

    SELECT activo INTO v_activo
    FROM ORGANIZACION WHERE id_organizacion = NEW.id_organizacion FOR UPDATE;
    IF NOT FOUND OR NOT v_activo THEN
        RAISE EXCEPTION 'La organización debe existir y estar activa.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_alta_pertenencia
BEFORE INSERT ON HISTORIAL_PERTENENCIA_ORGANIZATIVA
FOR EACH ROW EXECUTE FUNCTION fn_validar_alta_pertenencia();

-- 8.2 Identificadores personales y catálogos.
CREATE OR REPLACE FUNCTION fn_proteger_dni_persona()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.dni IS DISTINCT FROM OLD.dni THEN
        RAISE EXCEPTION
            'El DNI es inmutable en operaciones ordinarias; las correcciones excepcionales requieren un procedimiento administrativo auditado.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_proteger_dni_persona
BEFORE UPDATE OF dni ON PERSONA
FOR EACH ROW EXECUTE FUNCTION fn_proteger_dni_persona();

CREATE OR REPLACE FUNCTION fn_proteger_estado_incidente()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        RAISE EXCEPTION 'Los estados de incidente no se eliminan físicamente.';
    END IF;

    IF NEW.codigo IS DISTINCT FROM OLD.codigo THEN
        RAISE EXCEPTION 'El código técnico de un estado es inmutable.';
    END IF;

    IF OLD.protegido AND NOT NEW.protegido THEN
        RAISE EXCEPTION 'No se puede retirar la protección de un estado protegido.';
    END IF;

    IF OLD.es_terminal AND NOT NEW.es_terminal THEN
        RAISE EXCEPTION 'La terminalidad de un estado no se puede retirar.';
    END IF;

    IF OLD.codigo IN ('REGISTRADO','EN_GESTION','PENDIENTE','RESUELTO')
       AND (NEW.protegido = FALSE OR NEW.activo = FALSE) THEN
        RAISE EXCEPTION 'Los cuatro estados iniciales no se pueden desproteger ni archivar.';
    END IF;

    IF NEW.es_terminal AND NOT OLD.es_terminal
       AND EXISTS (
           SELECT 1 FROM TRANSICION_ESTADO_INCIDENTE t
           WHERE t.id_estado_origen = OLD.id_estado_incidente
             AND t.activo = TRUE
       ) THEN
        RAISE EXCEPTION 'Antes de convertir un estado en terminal, retire sus transiciones salientes.';
    END IF;

    IF OLD.activo AND NOT NEW.activo
       AND EXISTS (
           SELECT 1 FROM INCIDENTE i
           WHERE i.id_estado_incidente = OLD.id_estado_incidente
             AND i.activo = TRUE
       ) THEN
        RAISE EXCEPTION 'No se puede archivar un estado utilizado por incidentes activos.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_proteger_estado_incidente
BEFORE UPDATE OR DELETE ON ESTADO_INCIDENTE
FOR EACH ROW EXECUTE FUNCTION fn_proteger_estado_incidente();

-- Una transición activa nunca puede salir de un estado terminal ni llegar a uno inactivo.
CREATE OR REPLACE FUNCTION fn_validar_transicion_catalogo()
RETURNS TRIGGER AS $$
DECLARE
    v_terminal BOOLEAN;
    v_activo BOOLEAN;
BEGIN
    IF TG_OP = 'DELETE' THEN
        RAISE EXCEPTION 'Las transiciones se desactivan; no se eliminan.';
    END IF;

    IF TG_OP = 'UPDATE' AND (
       NEW.id_estado_origen IS DISTINCT FROM OLD.id_estado_origen
       OR NEW.id_estado_destino IS DISTINCT FROM OLD.id_estado_destino
    ) THEN
        RAISE EXCEPTION 'La identidad de una transición es inmutable.';
    END IF;

    IF NEW.activo THEN
        SELECT es_terminal, activo INTO v_terminal, v_activo
        FROM ESTADO_INCIDENTE
        WHERE id_estado_incidente = NEW.id_estado_origen
        FOR UPDATE;
        IF NOT FOUND OR NOT v_activo OR v_terminal THEN
            RAISE EXCEPTION 'El estado de origen debe estar activo y no ser terminal.';
        END IF;

        SELECT activo INTO v_activo
        FROM ESTADO_INCIDENTE
        WHERE id_estado_incidente = NEW.id_estado_destino
        FOR UPDATE;
        IF NOT FOUND OR NOT v_activo THEN
            RAISE EXCEPTION 'El estado de destino debe estar activo.';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_transicion_catalogo
BEFORE INSERT OR UPDATE OR DELETE ON TRANSICION_ESTADO_INCIDENTE
FOR EACH ROW EXECUTE FUNCTION fn_validar_transicion_catalogo();

-- 8.3 Transiciones efectivas de INCIDENTE.
CREATE OR REPLACE FUNCTION fn_validar_transicion_incidente()
RETURNS TRIGGER AS $$
DECLARE
    v_terminal_origen BOOLEAN;
    v_activo_destino BOOLEAN;
    v_transicion_activa BOOLEAN;
BEGIN
    IF NEW.id_estado_incidente IS NOT DISTINCT FROM OLD.id_estado_incidente THEN
        RETURN NEW;
    END IF;

    IF OLD.activo = FALSE OR NEW.activo = FALSE THEN
        RAISE EXCEPTION 'No se puede cambiar el estado de un incidente archivado.';
    END IF;

    -- Bloquear primero la transición del catálogo. Así, una
    -- desactivación concurrente espera a que termine este cambio de estado.
    SELECT activo
    INTO v_transicion_activa
    FROM TRANSICION_ESTADO_INCIDENTE
    WHERE id_estado_origen = OLD.id_estado_incidente
      AND id_estado_destino = NEW.id_estado_incidente
    FOR UPDATE;

    IF NOT FOUND OR NOT v_transicion_activa THEN
        RAISE EXCEPTION 'La transición solicitada no está autorizada en el catálogo.';
    END IF;

    -- Después se bloquean los estados para comprobar su vigencia.
    -- Se sigue el mismo orden de bloqueo que el trigger del catálogo.
    SELECT es_terminal INTO v_terminal_origen
    FROM ESTADO_INCIDENTE
    WHERE id_estado_incidente = OLD.id_estado_incidente
    FOR UPDATE;

    IF NOT FOUND OR v_terminal_origen THEN
        RAISE EXCEPTION 'Un incidente en estado terminal no puede reabrirse.';
    END IF;

    SELECT activo INTO v_activo_destino
    FROM ESTADO_INCIDENTE
    WHERE id_estado_incidente = NEW.id_estado_incidente
    FOR UPDATE;

    IF NOT FOUND OR NOT v_activo_destino THEN
        RAISE EXCEPTION 'El estado de destino debe estar activo.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_transicion_incidente
BEFORE UPDATE OF id_estado_incidente ON INCIDENTE
FOR EACH ROW EXECUTE FUNCTION fn_validar_transicion_incidente();



-- Los incidentes archivados no admiten cambios operativos; solo restauración lógica.
CREATE OR REPLACE FUNCTION fn_proteger_incidente_archivado()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.activo=TRUE AND NEW.activo=FALSE AND (
        NEW.id_organizacion IS DISTINCT FROM OLD.id_organizacion OR
        NEW.id_tipo_incidente IS DISTINCT FROM OLD.id_tipo_incidente OR
        NEW.id_estado_incidente IS DISTINCT FROM OLD.id_estado_incidente OR
        NEW.id_ubicacion IS DISTINCT FROM OLD.id_ubicacion OR
        NEW.titulo IS DISTINCT FROM OLD.titulo OR
        NEW.descripcion IS DISTINCT FROM OLD.descripcion OR
        NEW.fecha_incidente IS DISTINCT FROM OLD.fecha_incidente
    ) THEN
        RAISE EXCEPTION 'El archivo no puede combinarse con cambios operativos del incidente.';
    END IF;

    IF OLD.activo=FALSE AND NEW.activo=FALSE AND (
        NEW.id_organizacion IS DISTINCT FROM OLD.id_organizacion OR
        NEW.id_tipo_incidente IS DISTINCT FROM OLD.id_tipo_incidente OR
        NEW.id_estado_incidente IS DISTINCT FROM OLD.id_estado_incidente OR
        NEW.id_ubicacion IS DISTINCT FROM OLD.id_ubicacion OR
        NEW.titulo IS DISTINCT FROM OLD.titulo OR
        NEW.descripcion IS DISTINCT FROM OLD.descripcion OR
        NEW.fecha_incidente IS DISTINCT FROM OLD.fecha_incidente
    ) THEN
        RAISE EXCEPTION 'Un incidente archivado no admite modificaciones operativas.';
    END IF;
    IF OLD.activo=FALSE AND NEW.activo=TRUE AND (
        NEW.id_organizacion IS DISTINCT FROM OLD.id_organizacion OR
        NEW.id_tipo_incidente IS DISTINCT FROM OLD.id_tipo_incidente OR
        NEW.id_estado_incidente IS DISTINCT FROM OLD.id_estado_incidente OR
        NEW.id_ubicacion IS DISTINCT FROM OLD.id_ubicacion OR
        NEW.titulo IS DISTINCT FROM OLD.titulo OR
        NEW.descripcion IS DISTINCT FROM OLD.descripcion OR
        NEW.fecha_incidente IS DISTINCT FROM OLD.fecha_incidente
    ) THEN
        RAISE EXCEPTION 'La reactivación no puede alterar los datos operativos del incidente.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_proteger_incidente_archivado
BEFORE UPDATE ON INCIDENTE
FOR EACH ROW EXECUTE FUNCTION fn_proteger_incidente_archivado();

CREATE OR REPLACE FUNCTION fn_validar_cambio_tipo_incidente()
RETURNS TRIGGER AS $$
DECLARE v_activo BOOLEAN;
BEGIN
    IF NEW.id_tipo_incidente IS DISTINCT FROM OLD.id_tipo_incidente THEN
        IF OLD.activo=FALSE OR NEW.activo=FALSE THEN
            RAISE EXCEPTION 'No se puede cambiar el tipo de un incidente archivado.';
        END IF;
        SELECT activo INTO v_activo FROM TIPO_INCIDENTE
        WHERE id_tipo_incidente=NEW.id_tipo_incidente FOR UPDATE;
        IF NOT FOUND OR NOT v_activo THEN
            RAISE EXCEPTION 'El nuevo tipo de incidente debe estar activo.';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_cambio_tipo_incidente
BEFORE UPDATE OF id_tipo_incidente ON INCIDENTE
FOR EACH ROW EXECUTE FUNCTION fn_validar_cambio_tipo_incidente();

-- 8.4 Vinculaciones persona-incidente.
CREATE OR REPLACE FUNCTION fn_validar_vinculacion_persona_incidente()
RETURNS TRIGGER AS $$
DECLARE
    v_activo BOOLEAN;
    v_terminal BOOLEAN;
BEGIN
    IF TG_OP = 'DELETE' THEN
        RAISE EXCEPTION 'Las vinculaciones se archivan; no se eliminan físicamente.';
    END IF;

    IF TG_OP = 'UPDATE' THEN
        IF NEW.id_persona IS DISTINCT FROM OLD.id_persona
           OR NEW.id_incidente IS DISTINCT FROM OLD.id_incidente
           OR NEW.tipo_vinculacion IS DISTINCT FROM OLD.tipo_vinculacion
           OR NEW.fecha_creacion IS DISTINCT FROM OLD.fecha_creacion THEN
            RAISE EXCEPTION 'La identidad de una vinculación es inmutable.';
        END IF;
    END IF;

    IF TG_OP = 'INSERT' THEN
        PERFORM 1
        FROM PERSONA
        WHERE id_persona = NEW.id_persona AND activo = TRUE
        FOR UPDATE;
        IF NOT FOUND THEN
            RAISE EXCEPTION 'La persona debe estar activa para crear la vinculación.';
        END IF;

        SELECT i.activo, e.es_terminal
        INTO v_activo, v_terminal
        FROM INCIDENTE i
        JOIN ESTADO_INCIDENTE e ON e.id_estado_incidente = i.id_estado_incidente
        WHERE i.id_incidente = NEW.id_incidente
        FOR UPDATE OF i;
        IF NOT FOUND OR NOT v_activo OR v_terminal THEN
            RAISE EXCEPTION 'El incidente debe estar activo y no terminal.';
        END IF;
    ELSIF TG_OP = 'UPDATE' AND OLD.activo = FALSE AND NEW.activo = TRUE THEN
        PERFORM 1
        FROM PERSONA
        WHERE id_persona = NEW.id_persona AND activo = TRUE
        FOR UPDATE;
        IF NOT FOUND THEN
            RAISE EXCEPTION 'La persona debe estar activa para reactivar la vinculación.';
        END IF;

        SELECT i.activo, e.es_terminal
        INTO v_activo, v_terminal
        FROM INCIDENTE i
        JOIN ESTADO_INCIDENTE e ON e.id_estado_incidente = i.id_estado_incidente
        WHERE i.id_incidente = NEW.id_incidente
        FOR UPDATE OF i;
        IF NOT FOUND OR NOT v_activo OR v_terminal THEN
            RAISE EXCEPTION 'El incidente debe estar activo y no terminal.';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_vinculacion_persona_incidente
BEFORE INSERT OR UPDATE OR DELETE ON VINCULACION_PERSONA_INCIDENTE
FOR EACH ROW EXECUTE FUNCTION fn_validar_vinculacion_persona_incidente();

-- 8.5 Asignaciones: solo se validan altas/reactivaciones; retirar siempre es posible.
CREATE OR REPLACE FUNCTION fn_validar_alta_asignacion()
RETURNS TRIGGER AS $$
DECLARE
    v_org_incidente BIGINT;
    v_activo BOOLEAN;
    v_org_destino BIGINT;
BEGIN
    IF TG_OP = 'DELETE' THEN
        RAISE EXCEPTION 'Las asignaciones se retiran; no se eliminan físicamente.';
    END IF;

    IF TG_OP = 'UPDATE' THEN
        IF NEW.id_incidente IS DISTINCT FROM OLD.id_incidente
           OR NEW.id_usuario IS DISTINCT FROM OLD.id_usuario
           OR NEW.id_unidad IS DISTINCT FROM OLD.id_unidad
           OR NEW.fecha_inicio IS DISTINCT FROM OLD.fecha_inicio THEN
            RAISE EXCEPTION 'La identidad de una asignación es inmutable.';
        END IF;
        IF OLD.activo = FALSE THEN
            IF NEW IS DISTINCT FROM OLD THEN
                RAISE EXCEPTION 'Una asignación retirada es inmutable; cree una nueva.';
            END IF;
            RETURN NEW;
        END IF;
        IF OLD.activo = TRUE AND NEW.activo = FALSE THEN
            IF NEW.fecha_fin IS NULL OR NEW.fecha_fin <= OLD.fecha_inicio THEN
                RAISE EXCEPTION 'La retirada requiere fecha_fin posterior a fecha_inicio.';
            END IF;
            RETURN NEW;
        END IF;
        IF NEW.fecha_fin IS DISTINCT FROM OLD.fecha_fin THEN
            RAISE EXCEPTION 'fecha_fin solo se establece al retirar la asignación.';
        END IF;
        RETURN NEW;
    END IF;

    SELECT id_organizacion INTO v_org_incidente
    FROM INCIDENTE
    WHERE id_incidente = NEW.id_incidente AND activo = TRUE
    FOR UPDATE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Solo se puede asignar un incidente activo.';
    END IF;

    IF NEW.id_usuario IS NOT NULL THEN
        SELECT activo INTO v_activo
        FROM USUARIO WHERE id_usuario = NEW.id_usuario FOR UPDATE;
        IF NOT FOUND OR NOT v_activo THEN
            RAISE EXCEPTION 'El usuario destinatario debe estar activo.';
        END IF;

        SELECT h.id_organizacion INTO v_org_destino
        FROM HISTORIAL_PERTENENCIA_ORGANIZATIVA h
        WHERE h.id_usuario = NEW.id_usuario
          AND h.fecha_inicio <= NEW.fecha_inicio
          AND (h.fecha_fin IS NULL OR NEW.fecha_inicio < h.fecha_fin)
        ORDER BY h.fecha_inicio DESC
        LIMIT 1;
        IF v_org_destino IS DISTINCT FROM v_org_incidente THEN
            RAISE EXCEPTION 'El usuario destinatario debe pertenecer a la organización del incidente.';
        END IF;
    ELSE
        SELECT u.id_organizacion, u.activo
        INTO v_org_destino, v_activo
        FROM UNIDAD_ORGANIZATIVA u
        WHERE u.id_unidad = NEW.id_unidad
        FOR UPDATE;
        IF NOT FOUND OR NOT v_activo OR v_org_destino IS DISTINCT FROM v_org_incidente THEN
            RAISE EXCEPTION 'La unidad debe estar activa y pertenecer a la organización del incidente.';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_alta_asignacion
BEFORE INSERT OR UPDATE OR DELETE ON ASIGNACION_INCIDENTE
FOR EACH ROW EXECUTE FUNCTION fn_validar_alta_asignacion();

-- 8.6 Documentos: destino inmutable; archivado lógico, nunca borrado físico.
CREATE OR REPLACE FUNCTION fn_proteger_documento_asociado()
RETURNS TRIGGER AS $$
DECLARE
    v_activo BOOLEAN;
BEGIN
    IF TG_OP = 'DELETE' THEN
        RAISE EXCEPTION 'Los documentos asociados no se eliminan físicamente.';
    END IF;

    IF TG_OP = 'UPDATE' THEN
        IF NEW.id_incidente IS DISTINCT FROM OLD.id_incidente
           OR NEW.id_persona IS DISTINCT FROM OLD.id_persona
           OR NEW.id_antecedente IS DISTINCT FROM OLD.id_antecedente
           OR NEW.fecha_creacion IS DISTINCT FROM OLD.fecha_creacion THEN
            RAISE EXCEPTION 'El destino y fecha de creación del documento son inmutables.';
        END IF;
        IF OLD.activo = FALSE AND NEW IS DISTINCT FROM OLD THEN
            RAISE EXCEPTION 'Un documento archivado es inmutable.';
        END IF;

        IF OLD.activo = TRUE AND NEW.activo = FALSE AND (
            NEW.nombre IS DISTINCT FROM OLD.nombre
            OR NEW.tipo_documento IS DISTINCT FROM OLD.tipo_documento
            OR NEW.descripcion IS DISTINCT FROM OLD.descripcion
            OR NEW.referencia_simulada IS DISTINCT FROM OLD.referencia_simulada
        ) THEN
            RAISE EXCEPTION
                'El archivo de un documento no puede combinarse con cambios de contenido.';
        END IF;

        RETURN NEW;
    END IF;

    IF NEW.id_incidente IS NOT NULL THEN
        SELECT activo INTO v_activo FROM INCIDENTE
        WHERE id_incidente = NEW.id_incidente FOR UPDATE;
    ELSIF NEW.id_persona IS NOT NULL THEN
        SELECT activo INTO v_activo FROM PERSONA
        WHERE id_persona = NEW.id_persona FOR UPDATE;
    ELSE
        SELECT activo INTO v_activo FROM ANTECEDENTE
        WHERE id_antecedente = NEW.id_antecedente FOR UPDATE;
    END IF;

    IF NOT FOUND OR NOT v_activo THEN
        RAISE EXCEPTION 'El destino del documento debe existir y estar activo al crearlo.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_proteger_documento_asociado
BEFORE INSERT OR UPDATE OR DELETE ON DOCUMENTO_ASOCIADO
FOR EACH ROW EXECUTE FUNCTION fn_proteger_documento_asociado();

-- 8.7 Organización, unidad, perfil y usuario: archivado condicionado.
CREATE OR REPLACE FUNCTION fn_proteger_archivado_organizacion()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.activo AND NOT NEW.activo THEN
        IF EXISTS (SELECT 1 FROM UNIDAD_ORGANIZATIVA WHERE id_organizacion=OLD.id_organizacion AND activo)
           OR EXISTS (SELECT 1 FROM HISTORIAL_PERTENENCIA_ORGANIZATIVA WHERE id_organizacion=OLD.id_organizacion AND fecha_fin IS NULL)
           OR EXISTS (SELECT 1 FROM INCIDENTE WHERE id_organizacion=OLD.id_organizacion AND activo)
           OR EXISTS (
               SELECT 1 FROM ASIGNACION_INCIDENTE a
               JOIN UNIDAD_ORGANIZATIVA u ON u.id_unidad=a.id_unidad
               WHERE u.id_organizacion=OLD.id_organizacion AND a.activo
           ) THEN
            RAISE EXCEPTION 'La organización mantiene unidades, usuarios, incidentes o asignaciones activas.';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_proteger_archivado_organizacion
BEFORE UPDATE OF activo ON ORGANIZACION
FOR EACH ROW EXECUTE FUNCTION fn_proteger_archivado_organizacion();

CREATE OR REPLACE FUNCTION fn_proteger_archivado_unidad()
RETURNS TRIGGER AS $$
DECLARE v_org_activa BOOLEAN;
BEGIN
    IF OLD.activo AND NOT NEW.activo THEN
        IF EXISTS (
            SELECT 1 FROM HISTORIAL_UNIDAD_USUARIO
            WHERE id_unidad=OLD.id_unidad AND fecha_fin IS NULL
        ) OR EXISTS (
            SELECT 1 FROM ASIGNACION_INCIDENTE
            WHERE id_unidad=OLD.id_unidad AND activo
        ) THEN
            RAISE EXCEPTION 'La unidad mantiene usuarios adscritos o asignaciones activas.';
        END IF;
    ELSIF NOT OLD.activo AND NEW.activo THEN
        SELECT activo INTO v_org_activa FROM ORGANIZACION
        WHERE id_organizacion=NEW.id_organizacion FOR UPDATE;
        IF NOT FOUND OR NOT v_org_activa THEN
            RAISE EXCEPTION 'No se puede reactivar una unidad con organización inactiva.';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_proteger_archivado_unidad
BEFORE UPDATE OF activo ON UNIDAD_ORGANIZATIVA
FOR EACH ROW EXECUTE FUNCTION fn_proteger_archivado_unidad();

CREATE OR REPLACE FUNCTION fn_proteger_perfil()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        RAISE EXCEPTION 'Los perfiles no se eliminan físicamente.';
    END IF;
    IF NEW.codigo IS DISTINCT FROM OLD.codigo THEN
        RAISE EXCEPTION 'El código de perfil es inmutable.';
    END IF;
    IF OLD.protegido AND NOT NEW.protegido THEN
        RAISE EXCEPTION 'No se puede retirar la protección de un perfil protegido.';
    END IF;
    IF OLD.protegido AND NOT NEW.activo THEN
        RAISE EXCEPTION 'Los perfiles base no se pueden archivar.';
    END IF;
    IF OLD.activo AND NOT NEW.activo AND EXISTS (
        SELECT 1 FROM HISTORIAL_PERFIL_USUARIO
        WHERE id_perfil=OLD.id_perfil AND fecha_fin IS NULL
    ) THEN
        RAISE EXCEPTION 'No se puede archivar un perfil con usuarios que lo tienen vigente.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_proteger_perfil
BEFORE UPDATE OR DELETE ON PERFIL
FOR EACH ROW EXECUTE FUNCTION fn_proteger_perfil();

CREATE OR REPLACE FUNCTION fn_proteger_archivado_usuario()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.activo AND NOT NEW.activo THEN
        IF EXISTS (SELECT 1 FROM ASIGNACION_INCIDENTE WHERE id_usuario=OLD.id_usuario AND activo)
           OR EXISTS (
               SELECT 1 FROM AVISO_SEGUIMIENTO
               WHERE id_usuario_gestion=OLD.id_usuario
                 AND activo=TRUE AND estado='EN_GESTION'
           ) THEN
            RAISE EXCEPTION 'El usuario mantiene asignaciones o avisos en gestión.';
        END IF;
        IF EXISTS (SELECT 1 FROM HISTORIAL_PERFIL_USUARIO WHERE id_usuario=OLD.id_usuario AND fecha_fin IS NULL)
           OR EXISTS (SELECT 1 FROM HISTORIAL_UNIDAD_USUARIO hu
                      JOIN HISTORIAL_PERTENENCIA_ORGANIZATIVA hp ON hp.id_historial=hu.id_historial
                      WHERE hp.id_usuario=OLD.id_usuario AND hu.fecha_fin IS NULL)
           OR EXISTS (SELECT 1 FROM HISTORIAL_PERTENENCIA_ORGANIZATIVA
                      WHERE id_usuario=OLD.id_usuario AND fecha_fin IS NULL) THEN
            RAISE EXCEPTION 'Antes de archivar el usuario deben cerrarse sus historiales de perfil, unidad y pertenencia.';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_proteger_archivado_usuario
BEFORE UPDATE OF activo ON USUARIO
FOR EACH ROW EXECUTE FUNCTION fn_proteger_archivado_usuario();



CREATE OR REPLACE FUNCTION fn_validar_unidad_organizativa()
RETURNS TRIGGER AS $$
DECLARE v_activo BOOLEAN;
BEGIN
    IF TG_OP='DELETE' THEN
        RAISE EXCEPTION 'Las unidades se archivan; no se eliminan físicamente.';
    END IF;
    IF TG_OP='UPDATE' AND NEW.id_organizacion IS DISTINCT FROM OLD.id_organizacion THEN
        RAISE EXCEPTION 'La organización propietaria de una unidad es inmutable.';
    END IF;
    IF TG_OP='INSERT' OR (TG_OP='UPDATE' AND OLD.activo=FALSE AND NEW.activo=TRUE) THEN
        SELECT activo INTO v_activo FROM ORGANIZACION
        WHERE id_organizacion=NEW.id_organizacion FOR UPDATE;
        IF NOT FOUND OR NOT v_activo THEN
            RAISE EXCEPTION 'La unidad requiere una organización activa.';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_unidad_organizativa
BEFORE INSERT OR UPDATE OR DELETE ON UNIDAD_ORGANIZATIVA
FOR EACH ROW EXECUTE FUNCTION fn_validar_unidad_organizativa();

-- 8.8 Avisos: reactivación lógica permitida sin reabrir estado terminal.
CREATE OR REPLACE FUNCTION fn_validar_aviso_seguimiento()
RETURNS TRIGGER AS $$
DECLARE
    v_activo BOOLEAN;
BEGIN
    IF TG_OP = 'DELETE' THEN
        RAISE EXCEPTION
            'Los avisos de seguimiento se archivan; no se eliminan físicamente.';
    END IF;

    -- ALTA: los avisos nacen activos, pendientes y sin responsable.
    IF TG_OP = 'INSERT' THEN
        IF NEW.estado <> 'PENDIENTE'
           OR NEW.id_usuario_gestion IS NOT NULL
           OR NEW.fecha_gestion IS NOT NULL
           OR NEW.activo IS DISTINCT FROM TRUE THEN
            RAISE EXCEPTION
                'Un aviso nuevo debe comenzar activo, PENDIENTE y sin responsable.';
        END IF;

        SELECT activo
        INTO v_activo
        FROM INCIDENTE
        WHERE id_incidente = NEW.id_incidente
        FOR UPDATE;

        IF NOT FOUND OR NOT v_activo THEN
            RAISE EXCEPTION
                'El aviso requiere un incidente activo.';
        END IF;

        RETURN NEW;
    END IF;

    -- IDENTIDAD INMUTABLE.
    IF NEW.id_incidente IS DISTINCT FROM OLD.id_incidente
      OR NEW.origen IS DISTINCT FROM OLD.origen
      OR NEW.clave_deduplicacion IS DISTINCT FROM OLD.clave_deduplicacion
      OR NEW.fecha_creacion IS DISTINCT FROM OLD.fecha_creacion THEN
        RAISE EXCEPTION
            'La identidad del aviso es inmutable.';
    END IF;

    -- AVISO ARCHIVADO: solo se permite reactivarlo
    -- conservando todos sus datos.
    IF OLD.activo = FALSE THEN
        IF NEW.activo = FALSE THEN
            IF NEW IS DISTINCT FROM OLD THEN
                RAISE EXCEPTION
                    'Un aviso archivado es inmutable.';
            END IF;
            RETURN NEW;
        END IF;

        IF OLD.estado NOT IN ('GESTIONADO', 'CANCELADO')
           OR NEW.estado IS DISTINCT FROM OLD.estado
           OR NEW.id_usuario_gestion IS DISTINCT FROM OLD.id_usuario_gestion
           OR NEW.fecha_gestion IS DISTINCT FROM OLD.fecha_gestion
           OR NEW.descripcion IS DISTINCT FROM OLD.descripcion
           OR NEW.fecha_creacion IS DISTINCT FROM OLD.fecha_creacion
           OR NEW.id_incidente IS DISTINCT FROM OLD.id_incidente
           OR NEW.origen IS DISTINCT FROM OLD.origen
           OR NEW.clave_deduplicacion IS DISTINCT FROM OLD.clave_deduplicacion THEN
            RAISE EXCEPTION
                'La reactivación solo permite cambiar activo y conservar el aviso terminal.';
        END IF;

        SELECT activo
        INTO v_activo
        FROM INCIDENTE
        WHERE id_incidente = NEW.id_incidente
        FOR UPDATE;

        IF NOT FOUND OR NOT v_activo THEN
            RAISE EXCEPTION
                'No se puede reactivar un aviso cuyo incidente está archivado.';
        END IF;

        RETURN NEW;
    END IF;

    -- ARCHIVADO: solo desde un estado terminal
    -- y sin modificar simultáneamente otros datos.
    IF OLD.activo = TRUE AND NEW.activo = FALSE THEN
        IF OLD.estado NOT IN ('GESTIONADO', 'CANCELADO')
           OR NEW.estado IS DISTINCT FROM OLD.estado
           OR NEW.id_usuario_gestion IS DISTINCT FROM OLD.id_usuario_gestion
           OR NEW.fecha_gestion IS DISTINCT FROM OLD.fecha_gestion
           OR NEW.descripcion IS DISTINCT FROM OLD.descripcion THEN
            RAISE EXCEPTION
                'Solo se pueden archivar avisos terminales sin modificar sus datos.';
        END IF;

        RETURN NEW;
    END IF;

    -- TRANSICIONES DE ESTADO.
    IF NEW.estado IS DISTINCT FROM OLD.estado THEN
        IF NOT (
            (OLD.estado = 'PENDIENTE'
                AND NEW.estado IN ('EN_GESTION', 'CANCELADO'))
            OR
            (OLD.estado = 'EN_GESTION'
                AND NEW.estado IN ('GESTIONADO', 'CANCELADO'))
        ) THEN
            RAISE EXCEPTION
                'Transición de aviso no permitida.';
        END IF;

        IF NEW.estado = 'EN_GESTION' THEN
            SELECT activo
            INTO v_activo
            FROM USUARIO
            WHERE id_usuario = NEW.id_usuario_gestion
            FOR UPDATE;

            IF NOT FOUND OR NOT v_activo THEN
                RAISE EXCEPTION
                    'El responsable debe ser un usuario activo.';
            END IF;

            NEW.fecha_gestion := clock_timestamp();

        ELSIF OLD.estado = 'PENDIENTE'
              AND NEW.estado = 'CANCELADO' THEN
            IF NEW.id_usuario_gestion IS NOT NULL
               OR NEW.fecha_gestion IS NOT NULL THEN
                RAISE EXCEPTION
                    'La cancelación desde PENDIENTE no lleva responsable.';
            END IF;

        ELSIF OLD.estado = 'EN_GESTION' THEN
            IF NEW.id_usuario_gestion IS DISTINCT FROM OLD.id_usuario_gestion
               OR NEW.fecha_gestion IS DISTINCT FROM OLD.fecha_gestion THEN
                RAISE EXCEPTION
                    'El responsable y fecha de gestión son inmutables.';
            END IF;
        END IF;

    ELSE
        IF NEW.id_usuario_gestion IS DISTINCT FROM OLD.id_usuario_gestion
           OR NEW.fecha_gestion IS DISTINCT FROM OLD.fecha_gestion THEN
            RAISE EXCEPTION
                'El responsable solo se establece al iniciar la gestión.';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 8.9 Alertas: responsable estable, evidencia de resolución y fechas inmutables.
CREATE OR REPLACE FUNCTION fn_validar_alerta_tecnica()
RETURNS TRIGGER AS $$
DECLARE
    v_usuario_activo BOOLEAN;
BEGIN
    -- PROHIBIR ELIMINACIÓN FÍSICA.
    IF TG_OP = 'DELETE' THEN
        RAISE EXCEPTION
            'Las alertas técnicas se conservan para garantizar la trazabilidad.';
    END IF;

    -- ALTA.
    IF TG_OP = 'INSERT' THEN
        IF NEW.estado <> 'NUEVA'
           OR NEW.fecha_resolucion IS NOT NULL
           OR NEW.fecha_cierre IS NOT NULL THEN
            RAISE EXCEPTION
                'Una alerta nueva debe comenzar NUEVA y sin fechas de resolución/cierre.';
        END IF;

        IF NEW.id_usuario_responsable IS NOT NULL THEN
            SELECT activo
            INTO v_usuario_activo
            FROM USUARIO
            WHERE id_usuario = NEW.id_usuario_responsable
            FOR UPDATE;

            IF NOT FOUND OR NOT v_usuario_activo THEN
                RAISE EXCEPTION
                    'El responsable inicial de la alerta debe estar activo.';
            END IF;
        END IF;

        RETURN NEW;
    END IF;

    -- IDENTIDAD INMUTABLE.
    IF NEW.codigo IS DISTINCT FROM OLD.codigo
       OR NEW.origen IS DISTINCT FROM OLD.origen
       OR NEW.recurso IS DISTINCT FROM OLD.recurso
       OR NEW.id_alerta_anterior IS DISTINCT FROM OLD.id_alerta_anterior
       OR NEW.primera_ocurrencia IS DISTINCT FROM OLD.primera_ocurrencia THEN
        RAISE EXCEPTION
            'La identidad de una alerta es inmutable.';
    END IF;

    -- UNA ALERTA CERRADA ES INMUTABLE.
    IF OLD.estado = 'CERRADA' AND NEW IS DISTINCT FROM OLD THEN
        RAISE EXCEPTION
            'Una alerta cerrada es inmutable.';
    END IF;

    -- LA OBSERVACIÓN FINAL SOLO SE INTRODUCE AL CERRAR.
    IF NEW.observacion_final IS DISTINCT FROM OLD.observacion_final
       AND NOT (OLD.estado = 'RESUELTA' AND NEW.estado = 'CERRADA') THEN
        RAISE EXCEPTION
            'La observación final solo puede establecerse al cerrar la alerta.';
    END IF;

    -- UNA ALERTA RESUELTA SOLO ADMITE EL CIERRE FORMAL.
    IF OLD.estado = 'RESUELTA' AND (
        NEW.id_usuario_responsable IS DISTINCT FROM OLD.id_usuario_responsable
        OR NEW.id_alerta_anterior IS DISTINCT FROM OLD.id_alerta_anterior
        OR NEW.codigo IS DISTINCT FROM OLD.codigo
        OR NEW.origen IS DISTINCT FROM OLD.origen
        OR NEW.recurso IS DISTINCT FROM OLD.recurso
        OR NEW.severidad IS DISTINCT FROM OLD.severidad
        OR NEW.descripcion IS DISTINCT FROM OLD.descripcion
        OR NEW.numero_ocurrencias IS DISTINCT FROM OLD.numero_ocurrencias
        OR NEW.primera_ocurrencia IS DISTINCT FROM OLD.primera_ocurrencia
        OR NEW.ultima_ocurrencia IS DISTINCT FROM OLD.ultima_ocurrencia
        OR NEW.fecha_resolucion IS DISTINCT FROM OLD.fecha_resolucion
    ) THEN
        RAISE EXCEPTION
            'Una alerta resuelta solo permite registrar su cierre y observación final.';
    END IF;

    -- CONTADOR Y ÚLTIMA OCURRENCIA NO PUEDEN RETROCEDER.
    IF NEW.numero_ocurrencias < OLD.numero_ocurrencias
       OR NEW.ultima_ocurrencia < OLD.ultima_ocurrencia THEN
        RAISE EXCEPTION
            'El contador y la última ocurrencia no pueden retroceder.';
    END IF;

    -- RESPONSABLE: NO SE PUEDE SUSTITUIR NI RETIRAR.
    IF OLD.id_usuario_responsable IS NOT NULL
       AND NEW.id_usuario_responsable IS DISTINCT FROM OLD.id_usuario_responsable THEN
        RAISE EXCEPTION
            'El responsable de una alerta no se puede sustituir ni retirar.';
    END IF;

    IF NEW.id_usuario_responsable IS NOT NULL
       AND NEW.id_usuario_responsable IS DISTINCT FROM OLD.id_usuario_responsable THEN

        SELECT activo
        INTO v_usuario_activo
        FROM USUARIO
        WHERE id_usuario = NEW.id_usuario_responsable
        FOR UPDATE;

        IF NOT FOUND OR NOT v_usuario_activo THEN
            RAISE EXCEPTION
                'El responsable de la alerta debe estar activo.';
        END IF;
    END IF;

    -- FECHA DE RESOLUCIÓN: SOLO SE ESTABLECE UNA VEZ.
    IF OLD.fecha_resolucion IS NOT NULL
       AND NEW.fecha_resolucion IS DISTINCT FROM OLD.fecha_resolucion THEN
        RAISE EXCEPTION
            'La fecha de resolución es inmutable una vez establecida.';
    END IF;

    IF OLD.fecha_resolucion IS NULL
       AND NEW.fecha_resolucion IS NOT NULL
       AND NOT (OLD.estado IS DISTINCT FROM NEW.estado
                AND NEW.estado = 'RESUELTA') THEN
        RAISE EXCEPTION
            'La fecha de resolución solo se establece al resolver la alerta.';
    END IF;

    -- FECHA DE CIERRE: SOLO LA ESTABLECE EL TRIGGER.
    IF NEW.fecha_cierre IS DISTINCT FROM OLD.fecha_cierre
       AND NOT (OLD.estado IS DISTINCT FROM NEW.estado
                AND NEW.estado = 'CERRADA') THEN
        RAISE EXCEPTION
            'La fecha de cierre solo se establece al cerrar la alerta.';
    END IF;

    -- TRANSICIONES DE ESTADO.
    IF NEW.estado IS DISTINCT FROM OLD.estado THEN

        IF NOT (
            (OLD.estado = 'NUEVA'
                AND NEW.estado IN ('EN_REVISION', 'RESUELTA'))
            OR
            (OLD.estado = 'EN_REVISION'
                AND NEW.estado = 'RESUELTA')
            OR
            (OLD.estado = 'RESUELTA'
                AND NEW.estado = 'CERRADA')
        ) THEN
            RAISE EXCEPTION
                'Transición de alerta no permitida.';
        END IF;

        IF NEW.estado = 'EN_REVISION'
           AND NEW.id_usuario_responsable IS NULL THEN
            RAISE EXCEPTION
                'Una alerta en revisión requiere responsable.';
        END IF;

        -- RESOLUCIÓN: EXIGE ACCIÓN CORRECTIVA Y VERIFICACIÓN.
        IF NEW.estado = 'RESUELTA' THEN

            IF NOT EXISTS (
                SELECT 1
                FROM ACTUACION_ALERTA
                WHERE id_alerta = OLD.id_alerta
                  AND tipo_actuacion = 'ACCION_CORRECTIVA'
            ) OR NOT EXISTS (
                SELECT 1
                FROM ACTUACION_ALERTA
                WHERE id_alerta = OLD.id_alerta
                  AND tipo_actuacion = 'VERIFICACION'
            ) THEN
                RAISE EXCEPTION
                    'Para resolver se requiere acción correctiva y verificación registradas.';
            END IF;

            NEW.fecha_resolucion := clock_timestamp();
        END IF;

        -- CIERRE: REQUIERE RESOLUCIÓN PREVIA Y OBSERVACIÓN FINAL.
        IF NEW.estado = 'CERRADA' THEN

            IF OLD.fecha_resolucion IS NULL
               OR NEW.observacion_final IS NULL
               OR BTRIM(NEW.observacion_final) = '' THEN
                RAISE EXCEPTION
                    'El cierre requiere resolución previa y observación final.';
            END IF;

            NEW.fecha_cierre := clock_timestamp();
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION fn_validar_actuacion_alerta()
RETURNS TRIGGER AS $$
DECLARE
    v_estado VARCHAR(20);
    v_activo BOOLEAN;
    v_primera_ocurrencia TIMESTAMPTZ;
BEGIN
    IF TG_OP IN ('UPDATE', 'DELETE') THEN
        RAISE EXCEPTION
            'Las actuaciones de alerta son append-only.';
    END IF;

    SELECT estado, primera_ocurrencia
    INTO v_estado, v_primera_ocurrencia
    FROM ALERTA_TECNICA
    WHERE id_alerta = NEW.id_alerta
    FOR UPDATE;

    IF NOT FOUND OR v_estado IN ('RESUELTA', 'CERRADA') THEN
        RAISE EXCEPTION
            'No se pueden añadir actuaciones a una alerta resuelta o cerrada.';
    END IF;

    IF NEW.fecha_actuacion < v_primera_ocurrencia THEN
        RAISE EXCEPTION
            'La actuación no puede ser anterior a la primera ocurrencia de la alerta.';
    END IF;

    IF NEW.id_usuario IS NOT NULL THEN
        SELECT activo
        INTO v_activo
        FROM USUARIO
        WHERE id_usuario = NEW.id_usuario
        FOR UPDATE;

        IF NOT FOUND OR NOT v_activo THEN
            RAISE EXCEPTION
                'El usuario que registra la actuación debe estar activo.';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_actuacion_alerta
BEFORE INSERT OR UPDATE OR DELETE ON ACTUACION_ALERTA
FOR EACH ROW EXECUTE FUNCTION fn_validar_actuacion_alerta();

-- 8.10 Versiones de umbral: corrección segura del caso DELETE y código canónico.
CREATE OR REPLACE FUNCTION fn_proteger_version_umbral()
RETURNS TRIGGER AS $$
DECLARE
    v_codigo TEXT;
    v_max_version INTEGER;
BEGIN
    IF TG_OP='DELETE' THEN
        RAISE EXCEPTION 'Las versiones de umbrales no se pueden eliminar.';
    END IF;

    v_codigo := CASE WHEN TG_OP='UPDATE' THEN OLD.codigo ELSE NEW.codigo END;
    PERFORM pg_advisory_xact_lock(hashtextextended(LOWER(BTRIM(v_codigo)), 0));

    IF NEW.codigo <> UPPER(BTRIM(NEW.codigo)) THEN
        RAISE EXCEPTION 'El código de umbral debe estar normalizado en mayúsculas.';
    END IF;

    IF TG_OP='UPDATE' THEN
        IF NEW.codigo IS DISTINCT FROM OLD.codigo
           OR NEW.version IS DISTINCT FROM OLD.version
           OR NEW.valor IS DISTINCT FROM OLD.valor
           OR NEW.severidad IS DISTINCT FROM OLD.severidad
           OR NEW.condicion IS DISTINCT FROM OLD.condicion
           OR NEW.fecha_efectiva IS DISTINCT FROM OLD.fecha_efectiva
           OR NEW.motivo IS DISTINCT FROM OLD.motivo THEN
            RAISE EXCEPTION 'El contenido de una versión de umbral es inmutable.';
        END IF;
        IF OLD.vigente=FALSE AND NEW.vigente=TRUE THEN
            RAISE EXCEPTION 'No se puede reactivar una versión histórica.';
        END IF;
        IF OLD.vigente=FALSE AND NEW IS DISTINCT FROM OLD THEN
            RAISE EXCEPTION 'Una versión histórica es inmutable.';
        END IF;
        RETURN NEW;
    END IF;

    SELECT COALESCE(MAX(version),0) INTO v_max_version
    FROM CONFIGURACION_UMBRAL
    WHERE codigo=NEW.codigo;
    IF NEW.version <> v_max_version+1 OR NOT NEW.vigente THEN
        RAISE EXCEPTION 'La nueva versión debe ser consecutiva y quedar vigente.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 8.11 Inmutabilidad de identificadores técnicos y reglas de catálogo adicionales.
CREATE OR REPLACE FUNCTION fn_proteger_identidad_catalogo()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP='DELETE' THEN
        RAISE EXCEPTION 'Los catálogos se archivan; no se eliminan físicamente.';
    END IF;
    IF TG_TABLE_NAME='tipo_incidente'
       AND NEW.nombre IS DISTINCT FROM OLD.nombre
       AND EXISTS (SELECT 1 FROM INCIDENTE WHERE id_tipo_incidente=OLD.id_tipo_incidente) THEN
        RAISE EXCEPTION 'No se renombra un tipo de incidente con registros históricos asociados.';
    END IF;
    IF TG_TABLE_NAME='tipo_antecedente'
       AND NEW.nombre IS DISTINCT FROM OLD.nombre
       AND EXISTS (SELECT 1 FROM ANTECEDENTE WHERE id_tipo_antecedente=OLD.id_tipo_antecedente) THEN
        RAISE EXCEPTION 'No se renombra un tipo de antecedente con registros históricos asociados.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_identidad_tipo_incidente
BEFORE UPDATE OR DELETE ON TIPO_INCIDENTE
FOR EACH ROW EXECUTE FUNCTION fn_proteger_identidad_catalogo();

CREATE TRIGGER trg_identidad_tipo_antecedente
BEFORE UPDATE OR DELETE ON TIPO_ANTECEDENTE
FOR EACH ROW EXECUTE FUNCTION fn_proteger_identidad_catalogo();

-- 8.12 Coherencia mínima de ejecuciones de proceso.
CREATE OR REPLACE FUNCTION fn_validar_ejecucion_proceso()
RETURNS TRIGGER AS $$
BEGIN
    -- No se permite eliminar ejecuciones.
    IF TG_OP = 'DELETE' THEN
        RAISE EXCEPTION
            'Las ejecuciones de proceso se conservan para trazabilidad.';
    END IF;

    -- ALTA: toda ejecución comienza en curso.
    IF TG_OP = 'INSERT' THEN
        IF NEW.estado <> 'EN_EJECUCION'
           OR NEW.fecha_fin IS NOT NULL THEN
            RAISE EXCEPTION
                'Una ejecución nueva debe comenzar EN_EJECUCION y sin fecha_fin.';
        END IF;

        RETURN NEW;
    END IF;

    -- IDENTIDAD INMUTABLE.
    IF NEW.codigo_proceso IS DISTINCT FROM OLD.codigo_proceso
       OR NEW.identificador_ejecucion IS DISTINCT FROM OLD.identificador_ejecucion
       OR NEW.numero_intento IS DISTINCT FROM OLD.numero_intento
       OR NEW.fecha_inicio IS DISTINCT FROM OLD.fecha_inicio THEN
        RAISE EXCEPTION
            'La identidad de una ejecución es inmutable.';
    END IF;

    -- Las ejecuciones finalizadas no pueden modificarse.
    IF OLD.estado IN ('COMPLETADA', 'FALLIDA') THEN
        IF NEW IS DISTINCT FROM OLD THEN
            RAISE EXCEPTION
                'Una ejecución finalizada es inmutable.';
        END IF;

        RETURN NEW;
    END IF;

    -- Solo se permiten estas transiciones.
    IF OLD.estado = 'EN_EJECUCION' THEN

        IF NEW.estado NOT IN (
            'EN_EJECUCION',
            'COMPLETADA',
            'FALLIDA'
        ) THEN
            RAISE EXCEPTION
                'Estado de ejecución no permitido.';
        END IF;

        -- La finalización registra automáticamente su fecha.
        IF NEW.estado IN ('COMPLETADA', 'FALLIDA') THEN
            NEW.fecha_fin := clock_timestamp();
        END IF;

    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_ejecucion_proceso
BEFORE INSERT OR UPDATE OR DELETE ON EJECUCION_PROCESO
FOR EACH ROW EXECUTE FUNCTION fn_validar_ejecucion_proceso();

-- =====================================================================
-- FIN BLOQUE 8: CORRECCIONES Y CONSOLIDACION
-- =====================================================================


COMMIT;
