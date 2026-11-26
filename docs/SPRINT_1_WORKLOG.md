# Registro de trabajo — Sprint 1

**Proyecto:** S.A.P.O. — Sistema Avanzado Policial Operativo  
**Periodo:** 19/11/2026–30/11/2026  
**Repositorio:** https://github.com/Zanguango/SAPO  
**Tablero:** https://github.com/users/Zanguango/projects/1

Este registro separa expresamente el trabajo que ya existía antes del Sprint 1 de las actividades realizadas durante la iteración. Las fechas se consignan solo cuando existe evidencia de su realización.

## 1. Situación previa al Sprint 1

Antes del 19/11/2026 ya había preparado el esquema SQL de S.A.P.O., creado la base local `sapo_db` y ejecutado el esquema en PostgreSQL. También existía trabajo previo sobre claves, restricciones, relaciones, funciones y triggers del modelo.

Este trabajo constituye la base de partida del proyecto. No lo contabilizo como esfuerzo realizado dentro del Sprint 1 ni le asigno fechas retrospectivas. La referencia documental única del diseño es [docs/DATABASE_DESIGN.md](DATABASE_DESIGN.md). El archivo SQL de referencia todavía no está incorporado al repositorio GitHub.

## 2. Trabajo realizado durante el Sprint 1

### 26/11/2026 — Repositorio, estructura y arquitectura (SAPO-001)

He revisado el repositorio y preparado la estructura inicial para documentación, backend, frontend, base de datos y pruebas. He documentado la arquitectura cliente-servidor por capas, las responsabilidades de interfaz, API REST, middleware, controladores, servicios, repositorios y persistencia. También he actualizado el README y añadido el `.gitignore`.

**Evidencia:** [commit a0fe474 — estructura inicial y arquitectura](https://github.com/Zanguango/SAPO/commit/a0fe474a61dae6a9aa9f8aad175941587faa2606).

Documentos:
- [Arquitectura](ARCHITECTURE.md)
- [Estructura del proyecto](PROJECT_STRUCTURE.md)
- [README](../README.md)

### 26/11/2026 — Revisión y documentación del modelo de datos (SAPO-003)

He revisado el esquema PostgreSQL que ya existía antes del Sprint 1 y he delimitado las entidades y relaciones necesarias para el circuito práctico de personas e incidentes. He documentado las claves, cardinalidades, restricciones y dependencias entre entidades en el único documento de diseño de la base de datos.

En pgAdmin 4 he comprobado que la instancia local utiliza PostgreSQL 18.7, esquema `public`, 24 tablas y 31 claves foráneas. También he consultado los datos existentes: una organización, siete tipos de incidente, cuatro estados y cinco transiciones; todavía no hay personas ni incidentes.

Los siete tipos de incidente muestran fecha de creación 17/11/2026, anterior al inicio del Sprint 1. El origen de la organización y de los tipos de incidente continúa pendiente de recuperar o reproducir mediante una carga controlada; se registra en la [tarea técnica #51](https://github.com/Zanguango/SAPO/issues/51). No he vuelto a insertar esos registros ni he recreado la base.

**Evidencias:** [commit a87c401 — modelo de datos y dependencias](https://github.com/Zanguango/SAPO/commit/a87c40150b7e558a3374de6cd819b5754cd1f4d1) y [commit 2f50042 — contraste de recuentos locales](https://github.com/Zanguango/SAPO/commit/2f50042998c52469f3c31d6a5416039ad75e4302).

Documentos:
- [Diseño de la base de datos — referencia única](DATABASE_DESIGN.md)
- [Estrategia de datos iniciales ficticios](../database/seeds/README.md)

### 26/11/2026 — Documentación del entorno (SAPO-028)

He documentado la conexión local a PostgreSQL, la base `sapo_db`, el esquema `public`, PostgreSQL 18.7 y pgAdmin 4 versión 9.19. He preparado `backend/.env.example` sin credenciales reales y he documentado los requisitos para preparar el futuro backend.

En CMD he comprobado que `node`, `npm`, `git` y `psql` no se reconocen como comandos. Esto puede deberse a que no estén instalados o a que sus rutas no estén incluidas en PATH. La conexión al servidor PostgreSQL sí funciona desde pgAdmin 4. La instalación o configuración de esas herramientas queda como preparación del Sprint 2.

**Evidencias:** [commit f4ac4d6 — entorno y checklist](https://github.com/Zanguango/SAPO/commit/f4ac4d601ad51009518fd12b0f1c3b78d9f5977b) y [commit 013d312 — plantilla de configuración](https://github.com/Zanguango/SAPO/commit/013d3124d7beadb9710ef84625a88764574e2c33).

Documentos:
- [Entorno de desarrollo](ENVIRONMENT.md)
- [Plantilla de variables de entorno](../backend/.env.example)

### 26/11/2026 — Seguridad, privacidad y datos ficticios (SAPO-030)

He preparado una checklist que documenta la naturaleza académica del prototipo, el uso exclusivo de datos ficticios, los perfiles previstos, los permisos en backend, la validación de entradas, la protección de secretos y las limitaciones de no producción. Las medidas que requieren código permanecen señaladas como pendientes de implementación.

**Evidencia:** [commit f4ac4d6 — checklist de seguridad y privacidad](https://github.com/Zanguango/SAPO/commit/f4ac4d601ad51009518fd12b0f1c3b78d9f5977b).

Documento: [Checklist de seguridad y privacidad](SECURITY_CHECKLIST.md).

## 3. Estado de las historias del Sprint 1 en GitHub

A 26/11/2026, las cuatro historias seleccionadas aparecen cerradas como `Done`:

| Historia | Estado |
|---|---|
| SAPO-001 — Repositorio, estructura y arquitectura | Done |
| SAPO-003 — Modelo de persistencia del circuito | Done |
| SAPO-028 — Documentación del entorno | Done |
| SAPO-030 — Seguridad, privacidad y datos ficticios | Done |

La [tarea técnica #51](https://github.com/Zanguango/SAPO/issues/51) permanece en estado Backlog como seguimiento de la procedencia y reproducibilidad de los datos de ORGANIZACION y TIPO_INCIDENTE. No debe confundirse con la creación inicial del esquema, que es trabajo previo al Sprint 1.

## 4. Pendientes y límites que siguen abiertos

- La justificación formal de 1FN, 2FN y 3FN para el modelo global sigue pendiente. No se da por acreditada por el mero recuento de tablas y claves.
- El archivo SQL de referencia no está todavía versionado en GitHub: `database/schema/` contiene solo `.gitkeep`. Por tanto, el repositorio no puede reconstruir la base desde cero.
- La procedencia o carga reproducible de ORGANIZACION y TIPO_INCIDENTE sigue abierta en la tarea #51.
- Node.js, npm, Git y el cliente `psql` deben instalarse o configurarse en PATH antes del desarrollo del backend en Sprint 2.
- Antes del cierre del 30/11/2026 se deben preparar el informe de avance, el vídeo de máximo cinco minutos y la planificación de la siguiente iteración, conforme a las instrucciones de la asignatura.

## 5. Criterio de trazabilidad

El diseño SQL y la primera ejecución de la base pertenecen al trabajo previo al Sprint 1. Las historias posteriores que reutilicen el esquema deberán enlazar [docs/DATABASE_DESIGN.md](DATABASE_DESIGN.md) y las evidencias existentes, sin volver a atribuirse la creación del modelo ni repetir su descripción como trabajo nuevo.

Cualquier modificación futura del modelo deberá vincularse a un requisito o historia y documentarse mediante el procedimiento de control de cambios de la asignatura.
