class ComparadorEspectrograma
  UMBRAL = 0.6

  def self.similitud(espectrograma_input, espectrograma_guardado, estrategia = 'coseno')
    if estrategia == 'mcff'
      similitud_estrategia_mfcc(espectrograma_input, espectrograma_guardado)
    else
      similitud_estrategia_coseno(espectrograma_input, espectrograma_guardado)
    end
  end

  def self.similitud_estrategia_coseno(input, guardado)
    perfil1 = input["perfil"] || perfil_espectral(input["frames"] || [])
    perfil2 = guardado["perfil"] || perfil_espectral(guardado["frames"] || [])

    return 0.0 if perfil1.empty? || perfil2.empty?

    similitud_coseno(perfil1, perfil2)
  end

  def self.similitud_estrategia_mfcc(input, guardado)
    mfcc1 = input["mfcc"]
    mfcc2 = guardado["mfcc"]

    return 0.0 if mfcc1.nil? || mfcc2.nil? || mfcc1.empty? || mfcc2.empty?

    n_coef = mfcc1.length
    n_frames1 = mfcc1[0].length
    n_frames2 = mfcc2[0].length
    min_frames = [n_frames1, n_frames2].min

    suma = 0.0
    validos = 0

    min_frames.times do |f|
      vec1 = n_coef.times.map { |k| mfcc1[k][f] }
      vec2 = n_coef.times.map { |k| mfcc2[k][f] }

      s = similitud_coseno(vec1, vec2)
      unless s.nan?
        suma += s
        validos += 1
      end
    end

    validos > 0 ? (suma / validos) : 0.0
  end

  def self.perfil_espectral(frames)
    return [] if frames.empty?

    bins = frames.map(&:length).min
    return [] if bins <= 1

    perfil = Array.new(bins - 1, 0.0)
    validos = 0

    frames.each do |frame|
      energia = frame.sum { |v| v.abs } / frame.length.to_f
      next if energia < 0.00001

      max_valor = frame[1..].max
      next if max_valor.nil? || max_valor <= 0.0001

      (1...bins).each { |i| perfil[i - 1] += Math.log(1.0 + frame[i]) }
      validos += 1
    end

    return [] if validos.zero?

    perfil.map! { |v| v / validos }

    radio = 2
    Array.new(perfil.length) do |i|
      ventana = perfil[[0, i - radio].max..[perfil.length - 1, i + radio].min]
      ventana.sum / ventana.length
    end
  end

  def self.similitud_coseno(a, b)
    n = [a.length, b.length].min
    return 0.0 if n.zero?

    dot = norm_a = norm_b = 0.0
    n.times do |i|
      dot   += a[i] * b[i]
      norm_a += a[i]**2
      norm_b += b[i]**2
    end

    denom = Math.sqrt(norm_a) * Math.sqrt(norm_b)
    denom < 1e-10 ? 0.0 : dot / denom
  end
end
