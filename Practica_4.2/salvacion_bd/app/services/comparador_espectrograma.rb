class ComparadorEspectrograma
  UMBRAL = 0.6

  def self.similitud(frames_input, frames_guardados)
    perfil1 = perfil_espectral(frames_input)
    perfil2 = perfil_espectral(frames_guardados)

    return 0.0 if perfil1.empty? || perfil2.empty?

    similitud_coseno(perfil1, perfil2)
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
