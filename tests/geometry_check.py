#!/usr/bin/env python3
"""
Parametric Enclosure Generator v13.1 — Geometry Checker
Analyzes STL files exported by OpenSCAD: bounding box, volume, genus, watertightness.
Requires: pip install numpy-stl trimesh
"""
import sys, json, struct, os, math
from pathlib import Path


def check_stl_basic(filepath):
    """Return {status, vertex_count, facet_count, bbox} using numpy-stl (lightweight)."""
    try:
        from stl.mesh import Mesh
    except ImportError:
        return {"status": "SKIP", "error": "numpy-stl not installed (pip install numpy-stl)"}

    try:
        mesh = Mesh.from_file(str(filepath))
        v = mesh.vectors.reshape(-1, 3)
        bbox = {
            "x_min": float(v[:, 0].min()), "x_max": float(v[:, 0].max()),
            "y_min": float(v[:, 1].min()), "y_max": float(v[:, 1].max()),
            "z_min": float(v[:, 2].min()), "z_max": float(v[:, 2].max()),
        }
        bbox["x_size"] = bbox["x_max"] - bbox["x_min"]
        bbox["y_size"] = bbox["y_max"] - bbox["y_min"]
        bbox["z_size"] = bbox["z_max"] - bbox["z_min"]

        return {
            "status": "OK",
            "vertex_count": len(mesh.vectors) * 3,
            "facet_count": len(mesh.vectors),
            "bounding_box": bbox,
            "volume_mm3": abs(mesh.get_mass_properties()[0]),
        }
    except Exception as e:
        return {"status": "FAIL", "error": str(e)}


def check_stl_watertight(filepath):
    """Return {is_watertight, genus, euler_characteristic} using trimesh."""
    try:
        import trimesh
    except ImportError:
        return {"status": "SKIP", "error": "trimesh not installed (pip install trimesh)"}

    try:
        m = trimesh.load(str(filepath))
        if isinstance(m, trimesh.Scene):
            m = trimesh.util.concatenate([g for g in m.geometry.values() if hasattr(g, 'faces')])

        if m is None or len(m.faces) == 0:
            return {"status": "FAIL", "error": "Empty mesh"}

        is_wt = m.is_watertight
        euler = m.euler_number if hasattr(m, 'euler_number') else None
        genus_val = None
        if is_wt and m.vertices.shape[0] > 0 and m.faces.shape[0] > 0:
            V = len(m.vertices)
            E = len(m.edges_unique) if hasattr(m, 'edges_unique') else (len(m.faces) * 3) // 2
            F = len(m.faces)
            genus_val = (2 - (V - E + F)) // 2

        return {
            "status": "OK",
            "is_watertight": bool(is_wt),
            "genus": genus_val,
            "vertex_count": len(m.vertices),
            "facet_count": len(m.faces),
            "bbox": {
                "x_size": float(m.bounds[1][0] - m.bounds[0][0]),
                "y_size": float(m.bounds[1][1] - m.bounds[0][1]),
                "z_size": float(m.bounds[1][2] - m.bounds[0][2]),
            },
            "volume_mm3": float(m.volume) if hasattr(m, 'volume') else None,
        }
    except Exception as e:
        return {"status": "FAIL", "error": str(e)}


def validate_bbox(actual_bbox, expected_size, tolerance=2.0):
    """Check that bbox dimensions are within tolerance of expected."""
    results = []
    for axis, key in [("X", "x_size"), ("Y", "y_size"), ("Z", "z_size")]:
        if key in expected_size and expected_size[key] is not None:
            actual = actual_bbox.get(key, 0)
            expected = expected_size[key]
            ok = abs(actual - expected) <= tolerance
            results.append({
                "axis": axis,
                "actual": round(actual, 2),
                "expected": expected,
                "tolerance": tolerance,
                "pass": ok
            })
    return results


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python geometry_check.py <file.stl> [--watertight] [--expected XxYxZ] [--tolerance N]")
        sys.exit(1)

    filepath = sys.argv[1]
    if not os.path.exists(filepath):
        print(json.dumps({"status": "FAIL", "error": f"File not found: {filepath}"}))
        sys.exit(1)

    watertight = "--watertight" in sys.argv

    if watertight:
        result = check_stl_watertight(filepath)
    else:
        result = check_stl_basic(filepath)

    # Bbox validation if --expected provided
    expected_idx = None
    for i, a in enumerate(sys.argv):
        if a == "--expected" and i + 1 < len(sys.argv):
            expected_idx = i + 1
            break

    if expected_idx:
        parts = sys.argv[expected_idx].split("x")
        if len(parts) == 3:
            try:
                expected = {"x_size": float(parts[0]), "y_size": float(parts[1]), "z_size": float(parts[2])}
                tol = 2.0
                for j, a in enumerate(sys.argv):
                    if a == "--tolerance" and j + 1 < len(sys.argv):
                        tol = float(sys.argv[j + 1])
                bbox = result.get("bounding_box", result.get("bbox", {}))
                if bbox:
                    result["bbox_validation"] = validate_bbox(bbox, expected, tol)
            except ValueError:
                pass

    print(json.dumps(result, indent=2, default=str))
