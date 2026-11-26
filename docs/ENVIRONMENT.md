# Entorno de desarrollo — estado inicial

## 1. Tecnologías del proyecto

| Componente | Tecnología prevista | Estado conocido |
|---|---|---|
| Backend | JavaScript, Node.js y Express | Pendiente de implementación. |
| Frontend | HTML, CSS y JavaScript | Pendiente de implementación. |
| Base de datos | PostgreSQL | Instalado y con la base `sapo_db` creada. |
| Administración de BD | pgAdmin | Herramienta utilizada para administrar la base local. |
| Control de versiones | Git y GitHub | Repositorio remoto público disponible. |
| Seguimiento | GitHub Projects | Tablero y Sprint 1 configurados. |

## 2. Base de datos existente

La base PostgreSQL `sapo_db` ya está creada en el entorno local y se ha ejecutado previamente el script SQL del esquema. En el Sprint 1 se revisará qué tablas, relaciones y restricciones son necesarias para el circuito práctico de personas e incidencias. No se recreará la base de datos sin una necesidad justificada.

## 3. Configuración que se utilizará cuando se implemente el backend

La futura API deberá recibir su configuración mediante variables de entorno. Los nombres previstos son:

- `PORT`: puerto HTTP de la API.
- `DB_HOST`: servidor PostgreSQL local o configurado.
- `DB_PORT`: puerto de PostgreSQL.
- `DB_NAME`: nombre de la base, inicialmente `sapo_db`.
- `DB_USER`: usuario de conexión.
- `DB_PASSWORD`: contraseña de conexión.

Los valores reales y las credenciales no deben incorporarse a este documento ni al repositorio. Se añadirá un archivo de ejemplo sin secretos cuando se prepare la conexión desde Node.js/Express.

## 4. Datos iniciales ficticios

El modelo puede requerir registros previos de entidades relacionadas para poder probar determinadas operaciones. La estrategia prevista es mantener scripts o fixtures de datos ficticios separados del script de esquema. El orden de carga deberá respetar las dependencias y claves foráneas. El detalle se concretará tras revisar el esquema existente en SAPO-003.

## 5. Alcance de este documento

Este documento describe el estado conocido y la configuración prevista. No afirma que el backend, la conexión API–PostgreSQL ni el frontend estén implementados. Esos trabajos se realizarán en iteraciones posteriores.
