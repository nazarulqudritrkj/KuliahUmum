-- ==============================================================================
-- SISTEM INFORMASI MAHASISWA KULIAH UMUM (SIM-KU)
-- Database Schema & Migration for Supabase (PostgreSQL)
-- Versi: Terintegrasi Jurusan TIK, 4 Program Studi, & Angkatan 2023-2026
-- ==============================================================================

-- 1. EXTENSIONS
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ==============================================================================
-- 2. TABLE DEFINITIONS
-- ==============================================================================

-- 2.1 TABEL PROFILES (Kemahasiswaan & Admin)
-- Terintegrasi dengan auth.users milik Supabase
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    nim TEXT UNIQUE,
    full_name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    jurusan TEXT DEFAULT 'Teknologi Informasi dan Komputer',
    fakultas TEXT DEFAULT 'Teknologi Informasi dan Komputer',
    prodi TEXT DEFAULT 'Teknologi Rekayasa Multimedia',
    angkatan TEXT DEFAULT '2024',
    phone_number TEXT DEFAULT '',
    role TEXT NOT NULL DEFAULT 'mahasiswa' CHECK (role IN ('mahasiswa', 'admin')),
    avatar_url TEXT DEFAULT '',
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Migrasi kolom jika tabel profiles sudah terlanjur dibuat sebelumnya
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS jurusan TEXT DEFAULT 'Teknologi Informasi dan Komputer';
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS fakultas TEXT DEFAULT 'Teknologi Informasi dan Komputer';
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS prodi TEXT DEFAULT 'Teknologi Rekayasa Multimedia';
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS angkatan TEXT DEFAULT '2024';

-- 2.2 TABEL EVENTS (Kuliah Umum)
CREATE TABLE IF NOT EXISTS public.events (
    id TEXT PRIMARY KEY DEFAULT ('ev-' || substr(md5(random()::text), 1, 8)),
    title TEXT NOT NULL,
    description TEXT DEFAULT '',
    speaker_name TEXT NOT NULL,
    speaker_title TEXT DEFAULT '',
    speaker_organization TEXT DEFAULT '',
    speaker_avatar TEXT DEFAULT '',
    date_time TIMESTAMPTZ NOT NULL,
    duration TEXT NOT NULL DEFAULT '2 Jam',
    location TEXT NOT NULL DEFAULT 'Auditorium Utama',
    event_type TEXT NOT NULL DEFAULT 'offline' CHECK (event_type IN ('offline', 'online', 'hybrid')),
    quota INTEGER NOT NULL DEFAULT 200,
    registered_count INTEGER NOT NULL DEFAULT 0,
    banner_gradient_index TEXT DEFAULT '0',
    materials_url TEXT DEFAULT '',
    category TEXT NOT NULL DEFAULT 'Teknologi & AI',
    status TEXT NOT NULL DEFAULT 'upcoming' CHECK (status IN ('upcoming', 'ongoing', 'completed', 'cancelled')),
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- 2.3 TABEL REGISTRATIONS (Pendaftaran Tiket & Presensi)
CREATE TABLE IF NOT EXISTS public.registrations (
    id TEXT PRIMARY KEY DEFAULT ('reg-' || substr(md5(random()::text), 1, 8)),
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    event_id TEXT REFERENCES public.events(id) ON DELETE CASCADE,
    ticket_code TEXT UNIQUE NOT NULL,
    status TEXT NOT NULL DEFAULT 'registered' CHECK (status IN ('registered', 'attended', 'absent', 'cancelled')),
    check_in_time TIMESTAMPTZ,
    check_out_time TIMESTAMPTZ,
    is_feedback_submitted BOOLEAN NOT NULL DEFAULT FALSE,
    is_certificate_claimed BOOLEAN NOT NULL DEFAULT FALSE,
    registered_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- 2.4 TABEL FEEDBACKS (Kuesioner Evaluasi)
CREATE TABLE IF NOT EXISTS public.feedbacks (
    id TEXT PRIMARY KEY DEFAULT ('fb-' || substr(md5(random()::text), 1, 8)),
    event_id TEXT REFERENCES public.events(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    rating_speaker NUMERIC(3,1) NOT NULL CHECK (rating_speaker BETWEEN 1 AND 5),
    rating_material NUMERIC(3,1) NOT NULL CHECK (rating_material BETWEEN 1 AND 5),
    rating_facilities NUMERIC(3,1) NOT NULL CHECK (rating_facilities BETWEEN 1 AND 5),
    comments TEXT DEFAULT '',
    submitted_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- 2.5 TABEL CERTIFICATES (E-Sertifikat Resmi)
CREATE TABLE IF NOT EXISTS public.certificates (
    id TEXT PRIMARY KEY DEFAULT ('cert-' || substr(md5(random()::text), 1, 8)),
    registration_id TEXT REFERENCES public.registrations(id) ON DELETE CASCADE,
    event_id TEXT REFERENCES public.events(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    certificate_number TEXT UNIQUE NOT NULL,
    student_name TEXT NOT NULL,
    student_nim TEXT NOT NULL,
    event_title TEXT NOT NULL,
    speaker_name TEXT NOT NULL,
    event_date TIMESTAMPTZ NOT NULL,
    pdf_url TEXT DEFAULT '',
    issued_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- ==============================================================================
-- 3. FUNCTIONS & TRIGGERS (OTOMATISASI DATABASE)
-- ==============================================================================

-- 3.1 Trigger otomatis sinkronisasi jumlah pendaftar (registered_count) di tabel events
CREATE OR REPLACE FUNCTION public.update_event_registered_count()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        UPDATE public.events
        SET registered_count = (
            SELECT COUNT(*) FROM public.registrations
            WHERE event_id = NEW.event_id AND status != 'cancelled'
        )
        WHERE id = NEW.event_id;
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        UPDATE public.events
        SET registered_count = (
            SELECT COUNT(*) FROM public.registrations
            WHERE event_id = OLD.event_id AND status != 'cancelled'
        )
        WHERE id = OLD.event_id;
        RETURN OLD;
    ELSIF (TG_OP = 'UPDATE') THEN
        UPDATE public.events
        SET registered_count = (
            SELECT COUNT(*) FROM public.registrations
            WHERE event_id = NEW.event_id AND status != 'cancelled'
        )
        WHERE id = NEW.event_id;
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_update_event_registered_count ON public.registrations;
CREATE TRIGGER trg_update_event_registered_count
    AFTER INSERT OR UPDATE OR DELETE ON public.registrations
    FOR EACH ROW EXECUTE FUNCTION public.update_event_registered_count();

-- 3.2 Trigger otomatis membuat record di profiles saat mahasiswa register di auth.users Supabase
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (
        id, 
        email, 
        full_name, 
        nim, 
        jurusan,
        fakultas, 
        prodi, 
        angkatan, 
        phone_number, 
        role
    )
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', 'Mahasiswa'),
        COALESCE(NEW.raw_user_meta_data->>'nim', ''),
        COALESCE(NEW.raw_user_meta_data->>'jurusan', NEW.raw_user_meta_data->>'fakultas', 'Teknologi Informasi dan Komputer'),
        COALESCE(NEW.raw_user_meta_data->>'jurusan', NEW.raw_user_meta_data->>'fakultas', 'Teknologi Informasi dan Komputer'),
        COALESCE(NEW.raw_user_meta_data->>'prodi', 'Teknologi Rekayasa Multimedia'),
        COALESCE(NEW.raw_user_meta_data->>'angkatan', '2024'),
        COALESCE(NEW.raw_user_meta_data->>'phone_number', ''),
        COALESCE(NEW.raw_user_meta_data->>'role', 'mahasiswa')
    )
    ON CONFLICT (id) DO UPDATE SET
        full_name = EXCLUDED.full_name,
        nim = EXCLUDED.nim,
        jurusan = EXCLUDED.jurusan,
        fakultas = EXCLUDED.fakultas,
        prodi = EXCLUDED.prodi,
        angkatan = EXCLUDED.angkatan,
        phone_number = EXCLUDED.phone_number;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ==============================================================================
-- 4. ROW LEVEL SECURITY (RLS) POLICIES
-- ==============================================================================

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.registrations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.feedbacks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.certificates ENABLE ROW LEVEL SECURITY;

-- 4.1 Policies untuk Events
DROP POLICY IF EXISTS "Events are viewable by everyone" ON public.events;
CREATE POLICY "Events are viewable by everyone" 
    ON public.events FOR SELECT USING (true);

DROP POLICY IF EXISTS "Admins can manage events" ON public.events;
CREATE POLICY "Admins can manage events" 
    ON public.events FOR ALL USING (auth.role() = 'authenticated');

-- 4.2 Policies untuk Profiles
DROP POLICY IF EXISTS "Profiles are viewable by authenticated users" ON public.profiles;
CREATE POLICY "Profiles are viewable by authenticated users" 
    ON public.profiles FOR SELECT USING (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
CREATE POLICY "Users can update own profile" 
    ON public.profiles FOR UPDATE USING (auth.uid() = id);

-- 4.3 Policies untuk Registrations
DROP POLICY IF EXISTS "Users can view registrations" ON public.registrations;
CREATE POLICY "Users can view registrations" 
    ON public.registrations FOR SELECT USING (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Users can create registration" ON public.registrations;
CREATE POLICY "Users can create registration" 
    ON public.registrations FOR INSERT WITH CHECK (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Users can update registration" ON public.registrations;
CREATE POLICY "Users can update registration" 
    ON public.registrations FOR UPDATE USING (auth.role() = 'authenticated');

-- 4.4 Policies untuk Feedbacks
DROP POLICY IF EXISTS "Feedbacks viewable by authenticated" ON public.feedbacks;
CREATE POLICY "Feedbacks viewable by authenticated" 
    ON public.feedbacks FOR SELECT USING (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Users can insert feedback" ON public.feedbacks;
CREATE POLICY "Users can insert feedback" 
    ON public.feedbacks FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- 4.5 Policies untuk Certificates
DROP POLICY IF EXISTS "Certificates are publicly viewable" ON public.certificates;
CREATE POLICY "Certificates are publicly viewable" 
    ON public.certificates FOR SELECT USING (true);

DROP POLICY IF EXISTS "Authenticated can issue certificates" ON public.certificates;
CREATE POLICY "Authenticated can issue certificates" 
    ON public.certificates FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- ==============================================================================
-- 5. INITIAL MASTER DATA (SEED DATA KULIAH UMUM)
-- ==============================================================================

INSERT INTO public.events (
    id, title, description, speaker_name, speaker_title, speaker_organization,
    speaker_avatar, date_time, duration, location, event_type, quota,
    registered_count, banner_gradient_index, category, status
)
VALUES
(
    'ev-ai-01',
    'Transformasi Generative AI & Masa Depan Talenta Digital 2026',
    'Membahas perkembangan mutakhir Artificial Intelligence, implementasi Agentic Workflow di industri global, serta kesiapan mahasiswa dalam menghadapi era otomasi cerdas.',
    'Dr. Gita Wirjawan, M.B.A.',
    'Educator, Founder & Former Minister',
    'Endeavor Indonesia & Ancora Group',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
    NOW() + INTERVAL '3 days 2 hours',
    '2.5 Jam (09.00 - 11.30 WIB)',
    'Auditorium Utama Lantai 3 / Zoom Hybrid',
    'hybrid',
    350,
    312,
    '0',
    'Teknologi & AI',
    'upcoming'
),
(
    'ev-cyber-02',
    'Kedaulatan Data & Strategi Pertahanan Cybersecurity Modern',
    'Menganalisis arsitektur pertahanan siber Zero-Trust, regulasi perlindungan data pribadi nasional (UU PDP), dan teknik mitigasi serangan ransomware perusahaan.',
    'Pratama Persadha, Ph.D.',
    'Chairman Lembaga Riset CISSReC',
    'Cyber Security Research Center',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
    NOW() + INTERVAL '7 days 5 hours',
    '2 Jam (13.30 - 15.30 WIB)',
    'Gedung Serbaguna Kampus A',
    'offline',
    250,
    250,
    '1',
    'Cybersecurity',
    'upcoming'
),
(
    'ev-startup-03',
    'Building Scalable Fintech: From MVP to Sustainable Profitability',
    'Strategi membangun produk finansial teknologi yang adaptif, kepatuhan regulasi OJK & BI, serta manajemen risiko likuiditas bagi pendiri startup muda.',
    'Anderson Sumarli',
    'Co-Founder & CEO Ajaib Group',
    'Ajaib Technologies',
    'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
    NOW() + INTERVAL '12 days 1 hour',
    '2 Jam (10.00 - 12.00 WIB)',
    'Zoom Webinar Internasional',
    'online',
    500,
    189,
    '2',
    'Kewirausahaan & Bisnis',
    'upcoming'
),
(
    'ev-climate-04',
    'Inovasi Smart Grid & Green Technology untuk Kota Berkelanjutan',
    'Kajian transisi energi bersih, elektrifikasi transportasi massal, dan sistem kelistrikan pintar pendukung Net Zero Emission 2060.',
    'Prof. Dr. Ir. Tri Mumpuni',
    'Social Entrepreneur & Renewable Energy Expert',
    'Institut Bisnis dan Ekonomi Kerakyatan',
    'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150',
    NOW() + INTERVAL '18 days 4 hours',
    '2.5 Jam (14.00 - 16.30 WIB)',
    'Auditorium Fakultas Teknik',
    'offline',
    200,
    88,
    '3',
    'Sains & Keberlanjutan',
    'upcoming'
)
ON CONFLICT (id) DO NOTHING;
